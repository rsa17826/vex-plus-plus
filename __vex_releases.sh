#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# vex_releases.sh
# Downloads every vex-plus-plus Windows release, extracts the .pck,
# detects the Godot version from the .exe, downloads the matching Linux
# export template, and produces a ready-to-run Linux build per release.
# =============================================================================

REPO="rsa17826/vex-plus-plus"
BASE_DIR="$(cd "$(dirname "$0")" && pwd)/vex-releases"
API="https://api.github.com/repos/$REPO/releases?per_page=100"
TEMPLATES_DIR="$BASE_DIR/_templates"   # cached Godot Linux templates by version

mkdir -p "$BASE_DIR" "$TEMPLATES_DIR"

# -----------------------------------------------------------------------------
# Detect Godot version embedded in a Windows .exe or .pck
# -----------------------------------------------------------------------------
detect_godot_version() {
  local file="$1"
  strings "$file" 2>/dev/null \
    | grep -oP 'Godot Engine v\K[0-9]+\.[0-9]+\.[0-9]+\.[a-z0-9.]+' \
    | head -1 \
    || strings "$file" 2>/dev/null \
    | grep -oP 'Godot Engine v\K[0-9]+\.[0-9]+[^\s"\\]+' \
    | head -1 \
    || echo "unknown"
}

# -----------------------------------------------------------------------------
# Download the Linux export template for a given Godot version string
# e.g. "4.3.stable" -> downloads from official mirrors
# Returns path to the extracted linux_release template binary
# -----------------------------------------------------------------------------
get_linux_template() {
  local ver="$1"
  local out="$TEMPLATES_DIR/$ver"
 
  if [[ -f "$out/linux_debug.x86_64" ]]; then
    echo "$out/linux_debug.x86_64"
    return
  fi
 
  mkdir -p "$out"
 
  # local major minor rest
  # major=$(echo "$ver" | cut -d. -f1)
  # minor=$(echo "$ver" | cut -d. -f2)
  # rest=$(echo "$ver" | cut -d. -f3-)
 
  # local zip_name template_url tag_ver
  # if [[ "$rest" == "stable" || -z "$rest" ]]; then
  #   # e.g. 4.3.stable -> tag: 4.3-stable, file: Godot_v4.3-stable_linux.x86_64.zip
  #   tag_ver="${major}.${minor}-${rest}"
  #   zip_name="Godot_v${tag_ver}_linux.x86_64.zip"
  #   template_url="https://downloads.godotengine.org/?version=${version_str}&flavor=${flavor}&slug=export_templates.tpz&platform=templates"

  # else
  #   # e.g. 4.5.beta6.official -> strip ".official", tag: 4.5-beta6
  #   local prerel
  #   prerel=$(echo "$rest" | sed 's/\.official$//' | sed 's/\.official\.//')
  #   tag_ver="${major}.${minor}-${prerel}"
  #   zip_name="Godot_v${tag_ver}_linux.x86_64.zip"
  #   template_url="https://github.com/godotengine/godot/releases/download/${tag_ver}/${zip_name}"
  # fi
 
  # echo "  Downloading Linux template for Godot $ver..." >&2
  # local zip_path="$out/template.zip"
 
  # if curl -fsSL -o "$zip_path" "$template_url"; then
  #   unzip -q "$zip_path" -d "$out"
  #   local bin
  #   bin=$(find "$out" -maxdepth 1 -type f -name "Godot_v*_linux.x86_64" | head -1)
  #   if [[ -n "$bin" ]]; then
  #     mv "$bin" "$out/linux.x86_64"
  #     chmod +x "$out/linux.x86_64"
  #     rm -f "$zip_path"
  #     echo "$out/linux.x86_64"
  #   else
  #     echo "unknown"
  #   fi
  # else
  #   echo "  Warning: could not download Linux template for $ver" >&2
  #   echo "  URL tried: $template_url" >&2
  #   echo "unknown"
  # fi
}


# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
echo "=== Fetching release list ==="
RELEASES_JSON=$(curl -fsSL "$API")

# TAGS=$(echo "$RELEASES_JSON" | python3 -c "
# import sys, json
# releases = json.load(sys.stdin)
# for r in sorted(releases, key=lambda r: r['tag_name']):
#     print(r['tag_name'])
# ")

# if [[ -z "$TAGS" ]]; then
#   echo "No releases found."
#   exit 1
# fi

# echo "Releases: $(echo "$TAGS" | tr '\n' ' ')"
# echo ""

SUMMARY_FILE="$BASE_DIR/versions.txt"
echo "# release | godot_version | linux_build" > "$SUMMARY_FILE"
LAUNCHER_DIR="/home/nyix/.local/share/launcher/rsa17826 - vex-plus-plus/versions/"
for SRC_DIR in "$LAUNCHER_DIR"/*/; do
  TAG=$(basename "$SRC_DIR")
  RELEASE_DIR="$BASE_DIR/$TAG"
  mkdir -p "$RELEASE_DIR"

  echo "=== Release: $TAG ==="

  # WIN_ZIP="$RELEASE_DIR/windows.zip"
  # WIN_URL="https://github.com/$REPO/releases/download/$TAG/windows.zip"

  # # Download windows zip if not cached
  # if [[ ! -f "$WIN_ZIP" ]]; then
  #   echo "  Downloading $WIN_URL"
  #   if ! curl -fsSL -o "$WIN_ZIP" "$WIN_URL"; then
  #     echo "  No windows.zip for $TAG, skipping."
  #     rm -f "$WIN_ZIP"
  #     echo "$TAG | unknown | skipped" >> "$SUMMARY_FILE"
  #     continue
  #   fi
  # else
  #   echo "  Already downloaded, skipping fetch."
  # fi

  # Extract only .exe and .pck
  echo "  Extracting .exe and .pck..."
  # unzip -q -o "$WIN_ZIP" "*.exe" "*.pck" -d "$RELEASE_DIR/win_extract" 2>/dev/null || true

  EXE=$(find "/home/nyix/.local/share/launcher/rsa17826 - vex-plus-plus/versions/$TAG" -name "vex.exe" | head -1)
  PCK=$(find "/home/nyix/.local/share/launcher/rsa17826 - vex-plus-plus/versions/$TAG" -name "*.pck" | head -1)

  # # Keep the PCK, discard the rest
  # if [[ -n "$PCK" ]]; then
  #   cp "$PCK" "$RELEASE_DIR/game.pck"
  #   echo "  PCK saved."
  # else
  #   # Godot can also embed the pck into the exe - try the exe itself
  #   echo "  No separate .pck found, checking if PCK is embedded in exe..."
  #   # if [[ -n "$EXE" ]]; then
  #   #   # Check for embedded pck magic bytes "GDPC"
  #   #   if strings "$EXE" 2>/dev/null | grep -q "GDPC"; then
  #   #     echo "  PCK is embedded in exe - Linux template will need same approach."
  #   #     echo "  Copying exe as embedded_pck_exe for reference."
  #   #     cp "$EXE" "$RELEASE_DIR/embedded_pck.exe"
  #   #   fi
  #   # fi
  # fi

  # Detect Godot version
  GODOT_VERSION="unknown"
  if [[ -n "$EXE" ]]; then
    GODOT_VERSION=$(detect_godot_version "$EXE")
    echo "  Godot version (from exe): $GODOT_VERSION"
  elif [[ -f "$RELEASE_DIR/game.pck" ]]; then
    GODOT_VERSION=$(detect_godot_version "$RELEASE_DIR/game.pck")
    echo "  Godot version (from pck): $GODOT_VERSION"
  fi

  echo "$GODOT_VERSION" > "$RELEASE_DIR/godot_version.txt"

  # Clean up extracted windows files
  # rm -rf "$RELEASE_DIR/win_extract"

  # Build Linux output
  LINUX_DIR="$RELEASE_DIR/linux"
  mkdir -p "$LINUX_DIR"
  LINUX_BUILD="$LINUX_DIR/vex"

  if [[ "$GODOT_VERSION" == "unknown" ]]; then
    echo "  Skipping Linux build: unknown Godot version"
    echo "$TAG | unknown | failed" >> "$SUMMARY_FILE"
    continue
  fi

  if [[ -f "$LINUX_BUILD" ]]; then
    echo "  Linux build already exists, skipping."
    echo "$TAG | $GODOT_VERSION | $LINUX_BUILD" >> "$SUMMARY_FILE"
    continue
  fi

  TEMPLATE=$(get_linux_template "$GODOT_VERSION")

  if [[ "$TEMPLATE" == "unknown" || ! -f "$TEMPLATE" ]]; then
    echo "  Could not get Linux template for $GODOT_VERSION."
    echo "  Manually place it at: $TEMPLATES_DIR/$GODOT_VERSION/linux.x86_64"
    echo "$TAG | $GODOT_VERSION | template_missing" >> "$SUMMARY_FILE"
    continue
  fi

  cp "$TEMPLATE" "$LINUX_BUILD"
  chmod +x "$LINUX_BUILD"

  if [[ -f "$RELEASE_DIR/game.pck" ]]; then
    cp "$RELEASE_DIR/game.pck" "$LINUX_DIR/game.pck"
    echo "  Linux build ready: $LINUX_DIR/"
    echo "$TAG | $GODOT_VERSION | ok" >> "$SUMMARY_FILE"
  else
    echo "  Binary placed but no PCK (may be embedded). Run manually:"
    echo "    $LINUX_BUILD"
    echo "$TAG | $GODOT_VERSION | no_separate_pck" >> "$SUMMARY_FILE"
  fi

  echo ""
done

echo ""
echo "=== Done ==="
echo ""
cat "$SUMMARY_FILE"
