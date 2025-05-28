extends Area2D

@export var rootNode: Node

var tempGroups = []

func on_respawn():
  # rootNode.position = Vector2.ZERO
  for group in tempGroups:
    rootNode.remove_from_group(group)
  tempGroups = []
  if rootNode.selectedOptions.attachesToThings:
    await global.wait()
    tryaddgroups()
  # tryaddgroups.call_deferred()

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
  or rootNode.is_in_group(group) \
  or group in tempGroups \
  : return
  tempGroups.append(group)
  rootNode.add_to_group(group)
  # log.pp(tempGroups, group, rootNode, rootNode.get_groups())
