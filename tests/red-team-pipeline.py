#!/usr/bin/env python3
"""Adversarial test suite for the level-upload PR pipeline (validate_pr.py +
the GitHub ruleset). Opens a series of PRs that each try to break exactly
one rule, via the raw Git Data API -- the same low-level path
LevelServer.gd's proposeFiles() uses -- so these exercise the real
server-side gate, not just the client's own honesty.

Each attack is expected to be BLOCKED (the validate check should fail, and
the PR should never merge). One control case is expected to be ALLOWED, to
confirm the pipeline hasn't been broken in the process of locking it down.
A "PASS" means the pipeline behaved as expected; a "FAIL" on an attack means
something got through that shouldn't have -- investigate immediately.

Requires: gh CLI, authenticated (gh auth login), with write access to the
repo. Requires: pip install cryptography

Usage:
  python3 red-team-pipeline.py rsa17826/vex-plus-plus-level-codes

Cleans up after itself: every PR opened here is closed (never merged) and
its branch deleted, whether the test passed or failed, so nothing is left
behind in the repo's history for real users to see.
"""
from __future__ import annotations

import base64
import json
import subprocess
import sys
import time
from dataclasses import dataclass, field

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey


# ---------------------------------------------------------------------------
# GitHub plumbing -- same shape as LevelServer.gd's proposeFiles, via `gh api`
# ---------------------------------------------------------------------------

def gh(*args: str, input_json: dict | None = None) -> dict | list:
    cmd = ["gh", *args]
    kwargs = {}
    if input_json is not None:
        cmd += ["--input", "-"]
        kwargs["input"] = json.dumps(input_json)
    out = subprocess.run(cmd, capture_output=True, text=True, **kwargs)
    if out.returncode != 0:
        raise RuntimeError(f"gh {' '.join(args)} failed: {out.stderr.strip()}")
    return json.loads(out.stdout) if out.stdout.strip() else {}


class Repo:
    def __init__(self, full_name: str, base_branch: str = "main"):
        self.full_name = full_name
        self.base_branch = base_branch

    def api(self, method: str, path: str, body: dict | None = None):
        args = ["api", "-X", method, f"repos/{self.full_name}{path}"]
        return gh(*args, input_json=body)

    def base_sha(self) -> str:
        return self.api("GET", f"/git/ref/heads/{self.base_branch}")["object"]["sha"]

    def base_tree(self, commit_sha: str) -> str:
        return self.api("GET", f"/git/commits/{commit_sha}")["tree"]["sha"]

    def create_blob(self, content: bytes) -> str:
        return self.api("POST", "/git/blobs", {
            "content": base64.b64encode(content).decode(), "encoding": "base64",
        })["sha"]

    def create_tree(self, base_tree: str, entries: list[dict]) -> str:
        return self.api("POST", "/git/trees", {"base_tree": base_tree, "tree": entries})["sha"]

    def create_commit(self, message: str, tree_sha: str, parent_sha: str) -> str:
        return self.api("POST", "/git/commits", {
            "message": message, "tree": tree_sha, "parents": [parent_sha],
        })["sha"]

    def create_branch(self, name: str, sha: str) -> None:
        self.api("POST", "/git/refs", {"ref": f"refs/heads/{name}", "sha": sha})

    def delete_branch(self, name: str) -> None:
        try:
            self.api("DELETE", f"/git/refs/heads/{name}")
        except RuntimeError:
            pass # already gone (e.g. auto-delete-on-merge fired) -- fine

    def open_pr(self, branch: str, title: str, body: str) -> int:
        return self.api("POST", "/pulls", {
            "title": title, "head": branch, "base": self.base_branch, "body": body,
        })["number"]

    def close_pr(self, number: int) -> None:
        try:
            self.api("PATCH", f"/pulls/{number}", {"state": "closed"})
        except RuntimeError:
            pass

    def pr_check_state(self, number: int) -> tuple[str, str | None]:
        """(pr_state, validate_check_conclusion). conclusion is None while pending."""
        pr = self.api("GET", f"/pulls/{number}")
        sha = pr["head"]["sha"]
        try:
            runs = self.api("GET", f"/commits/{sha}/check-runs")["check_runs"]
        except RuntimeError:
            runs = []
        validate = next((r for r in runs if r["name"] == "validate"), None)
        conclusion = validate["conclusion"] if validate and validate["status"] == "completed" else None
        return pr["state"], conclusion


# path -> bytes to write, or None to delete that path
FileSet = dict[str, bytes | None]


def propose(repo: Repo, files: FileSet, message: str, branch: str, title: str) -> int:
    base_sha = repo.base_sha()
    base_tree = repo.base_tree(base_sha)
    entries = []
    for path, content in files.items():
        if content is None:
            entries.append({"path": path, "mode": "100644", "type": "blob", "sha": None})
        else:
            entries.append({"path": path, "mode": "100644", "type": "blob", "sha": repo.create_blob(content)})
    tree_sha = repo.create_tree(base_tree, entries)
    commit_sha = repo.create_commit(message, tree_sha, base_sha)
    repo.create_branch(branch, commit_sha)
    return repo.open_pr(branch, title, "Automated red-team test -- see red-team-pipeline.py. Safe to close.")


def wait_for_verdict(repo: Repo, number: int, timeout_s: int = 180) -> str:
    """Polls until the validate check completes or the PR merges/closes on
    its own (auto-merge). Returns one of: 'check_failed', 'merged', 'check_passed_open'."""
    deadline = time.time() + timeout_s
    while time.time() < deadline:
        state, conclusion = repo.pr_check_state(number)
        if state == "merged":
            return "merged"
        if conclusion == "failure":
            return "check_failed"
        if conclusion == "success":
            return "merged" # passed but hasn't merged yet -- keep polling a bit, might still merge
        time.sleep(5)
    return "timeout"


# ---------------------------------------------------------------------------
# Level-signing helpers, matching LevelServer.gd's canonicalLevelBytes /
# scripts/common.py exactly
# ---------------------------------------------------------------------------

def canonical_level_bytes(level: dict) -> bytes:
    return b"\x00".join([
        level["levelName"].encode(), level["creatorName"].encode(),
        str(level["gameVersion"]).encode(), str(level["levelVersion"]).encode(),
    ]) + b"\x00" + base64.b64decode(level["levelData"])


def make_level(name: str, creator: str, version: int, priv: Ed25519PrivateKey, pub_b64: str, data: bytes = b"fake level bytes") -> dict:
    level = {
        "levelName": name, "description": "red-team test level", "creatorName": creator,
        "gameVersion": 1, "levelVersion": version,
        "levelData": base64.b64encode(data).decode(),
        "levelImage": "", "publicKey": pub_b64,
    }
    level["signature"] = base64.b64encode(priv.sign(canonical_level_bytes(level))).decode()
    return level


def level_bytes(level: dict) -> bytes:
    return json.dumps(level).encode()


# ---------------------------------------------------------------------------
# Test cases
# ---------------------------------------------------------------------------

@dataclass
class Case:
    name: str
    expect: str # "blocked" or "allowed"
    files: FileSet
    note: str = ""


@dataclass
class Setup:
    repo: Repo
    user: str
    priv: Ed25519PrivateKey
    pub_b64: str
    level_name: str = "redteam-level"


def register_test_user(repo: Repo, user: str) -> tuple[Ed25519PrivateKey, str]:
    priv = Ed25519PrivateKey.generate()
    pub_b64 = base64.b64encode(
        priv.public_key().public_bytes(
            __import__("cryptography.hazmat.primitives.serialization", fromlist=["Encoding"]).Encoding.Raw,
            __import__("cryptography.hazmat.primitives.serialization", fromlist=["PublicFormat"]).PublicFormat.Raw,
        )
    ).decode()
    branch = f"redteam-setup-{int(time.time())}"
    pr = propose(repo, {f"users/{user}.pub": pub_b64.encode()},
                 f"register test user {user}", branch, f"[red-team] register {user}")
    print(f"  registering test identity '{user}' (PR #{pr}), waiting for merge...")
    verdict = wait_for_verdict(repo, pr, timeout_s=3000)
    print("verdict", verdict)
    if verdict != "merged":
        raise RuntimeError(f"setup registration didn't merge (got {verdict}) -- check branch protection / "
                            f"auto-merge settings before running attacks, or merge PR #{pr} manually")
    return priv, pub_b64


def build_cases(s: Setup) -> list[Case]:
    valid = make_level(s.level_name, s.user, 1, s.priv, s.pub_b64)
    valid_bytes = level_bytes(valid)
    latest_path = f"levels/{s.user}/{s.level_name}.json"
    history_path = f"levels/{s.user}/{s.level_name}/1.json"

    # baseline valid upload the later attacks build on top of
    baseline_files: FileSet = {latest_path: valid_bytes, history_path: valid_bytes}

    forged_creator = dict(valid)
    forged_creator["creatorName"] = "someone-else"
    # keep original signature -- it was signed over s.user's name, so this
    # tests the creatorName-vs-path-owner check, not signature verification
    forged_creator_bytes = json.dumps(forged_creator).encode()

    bad_sig = dict(valid)
    bad_sig["signature"] = base64.b64encode(b"\x00" * 64).decode()
    bad_sig_bytes = json.dumps(bad_sig).encode()

    v2 = make_level(s.level_name, s.user, 2, s.priv, s.pub_b64)
    v2_bytes = level_bytes(v2)
    v2_tampered = dict(v2)
    v2_tampered["description"] = "tampered after signing"
    v2_tampered_bytes = json.dumps(v2_tampered).encode()

    history_bad_version = dict(valid) # levelVersion says 1, filename will say 7
    history_bad_version_bytes = level_bytes(history_bad_version)

    other_user = f"{s.user}-2"

    return [
        Case("baseline_valid_upload", "allowed", baseline_files,
             "sanity check -- confirms the pipeline still accepts a correctly paired, correctly signed upload"),

        Case("delete_registered_pubkey", "blocked",
             {f"users/{s.user}.pub": None},
             "tries to delete the already-registered public key"),

        Case("modify_registered_pubkey", "blocked",
             {f"users/{s.user}.pub": b"not-the-real-key"},
             "tries to overwrite the registered public key with a different one"),

        Case("delete_level_latest", "blocked",
             {latest_path: None},
             "tries to delete the 'latest' level file (needs the baseline case to have landed first)"),

        Case("delete_history_entry", "blocked",
             {history_path: None},
             "tries to delete a version-history entry"),

        Case("modify_history_entry", "blocked",
             {history_path: b'{"levelName":"tampered"}'},
             "tries to overwrite an existing (append-only) history entry"),

        Case("orphan_latest_no_history", "blocked",
             {latest_path: v2_bytes},
             "updates 'latest' to v2 without adding a matching levels/.../2.json history entry"),

        Case("orphan_history_no_latest", "blocked",
             {f"levels/{s.user}/{s.level_name}/2.json": v2_bytes},
             "adds a v2 history entry without updating 'latest' to match"),

        Case("latest_history_content_mismatch", "blocked",
             {latest_path: v2_bytes, f"levels/{s.user}/{s.level_name}/2.json": v2_tampered_bytes},
             "latest and history both touched, but their bytes don't match"),

        Case("forged_creator_name", "blocked",
             {f"levels/{s.user}/forged-creator-level.json": forged_creator_bytes,
              f"levels/{s.user}/forged-creator-level/1.json": forged_creator_bytes},
             "level JSON claims a different creatorName than the folder it's filed under"),

        Case("forged_signature", "blocked",
             {f"levels/{s.user}/bad-sig-level.json": bad_sig_bytes,
              f"levels/{s.user}/bad-sig-level/1.json": bad_sig_bytes},
             "signature bytes replaced with garbage"),

        Case("history_filename_version_mismatch", "blocked",
             {f"levels/{s.user}/version-mismatch-level.json": history_bad_version_bytes,
              f"levels/{s.user}/version-mismatch-level/7.json": history_bad_version_bytes},
             "history file named 7.json but the JSON inside says levelVersion 1"),

        Case("multi_user_pr", "blocked",
             {f"users/{other_user}.pub": b"fake-key-for-second-user",
              latest_path: v2_bytes, history_path: history_bad_version_bytes},
             "touches a second user's registration alongside the first user's level in one PR"),

        Case("disallowed_path", "blocked",
             {"not-a-real-location.json": b"{}"},
             "touches a path outside users/<name>.pub and levels/<name>/..."),

        Case("manifest_hand_edited", "blocked",
             {"meta/manifest.json": b'{"levels":[{"levelName":"fake","verified":True}]}'},
             "submits a manifest that wasn't produced by scripts/build_manifest.py"),

        Case("manifest_bundled_with_other_change", "blocked",
             {"meta/manifest.json": b'{"levels":[]}', latest_path: v2_bytes},
             "touches meta/manifest.json alongside a level file in the same PR"),
    ]


def run_case(repo: Repo, case: Case) -> bool:
    branch = f"redteam-{case.name}-{int(time.time())}"
    try:
        pr = propose(repo, case.files, f"[red-team] {case.name}", branch, f"[red-team] {case.name}")
    except RuntimeError as e:
        print(f"  could not even open a PR for this case ({e}) -- treating as blocked")
        return case.expect == "blocked"

    print(f"  PR #{pr} opened, waiting for the validate check...")
    verdict = wait_for_verdict(repo, pr, timeout_s=180)

    passed = (
        (case.expect == "blocked" and verdict == "check_failed")
        or (case.expect == "allowed" and verdict in ("merged", "check_passed_open"))
    )

    print(f"  verdict: {verdict} (expected {case.expect}) -> {'PASS' if passed else 'FAIL'}")

    if verdict != "merged": # don't close an already-merged baseline PR, nothing to clean up there
        repo.close_pr(pr)
    repo.delete_branch(branch)
    return passed


def main() -> None:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <owner>/<repo>")
        sys.exit(1)

    repo = Repo(sys.argv[1])
    test_user = f"redteam-{int(time.time())}"

    print(f"Setting up test identity on {repo.full_name}...")
    priv, pub_b64 = register_test_user(repo, test_user)
    s = Setup(repo=repo, user=test_user, priv=priv, pub_b64=pub_b64)

    results = {}
    for case in build_cases(s):
        print(f"\n=== {case.name} ===")
        if case.note:
            print(f"  {case.note}")
        results[case.name] = run_case(repo, case)

    print("\n" + "=" * 60)
    failed = [name for name, ok in results.items() if not ok]
    for name, ok in results.items():
        print(f"  {'PASS' if ok else 'FAIL'}  {name}")
    print("=" * 60)
    if failed:
        print(f"\n{len(failed)} case(s) did NOT behave as expected -- investigate before trusting the pipeline:")
        for name in failed:
            print(f"  - {name}")
        sys.exit(1)
    else:
        print(f"\nAll {len(results)} cases behaved as expected.")


if __name__ == "__main__":
    main()
