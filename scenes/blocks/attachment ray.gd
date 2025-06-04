extends Area2D

@export var root: Node

var tempGroups = []

func on_respawn():
  # root.position = Vector2.ZERO
  for group in tempGroups:
    root.remove_from_group(group)
  await global.wait()
  clearAllGroups()
  if not root or 'selectedOptions' not in root or 'attachesToThings' not in root.selectedOptions:
    if root:
      log.err(root, root.id)
    else:
      log.err("root not set")
    breakpoint
  if root.selectedOptions.attachesToThings:
    await global.wait()
    tryaddgroups()
  # tryaddgroups.call_deferred()

func clearAllGroups():
  for group in tempGroups:
    root.remove_from_group(group)
  tempGroups = []

func tryaddgroups():
  for block in get_overlapping_bodies():
    # log.pp(block, "is overlapping")
    for group in block.get_parent().get_groups():
      if block.get_parent().is_in_group("canBeAttachedTo"):
        tryadd(group)
    for group in block.get_groups():
      if block.is_in_group("canBeAttachedTo"):
        tryadd(group)

func tryadd(group):
  # log.pp("trying to add", group)
  if global.starts_with(group, "_vp_") \
  or global.starts_with(group, "EDITOR_OPTION") \
  or group == "respawnOnPlayerDeath" \
  or root.is_in_group(group) \
  or group in tempGroups \
  : return
  tempGroups.append(group)
  root.add_to_group(group)
  # log.pp(tempGroups, group, root, root.get_groups())
