extends Area2D

@export var root: Editor

# var tempGroups = []
var attachments = []
var following = true

func on_respawn():
  # root.position = Vector2.ZERO
  # disableAllGroups()
  # tempGroups = []
  attachments = []
  if not root or 'selectedOptions' not in root or 'attachesToThings' not in root.selectedOptions:
    if root:
      log.err(root, root.id)
    else:
      log.err("root not set", name, get_parent().id, get_parent().get_parent().id, get_parent().get_parent().get_parent().id)
    breakpoint
  if root.selectedOptions.attachesToThings:
    following = true
    await global.wait()
    await global.wait()
    await global.wait()
    await global.wait()
    await global.wait()
    tryaddgroups()
    await global.wait()
    tryaddgroups()
    await global.wait()
    tryaddgroups()
    log.pp(attachments, root.id)

func on_physics_process(delta: float) -> void:
  if not following: return
  for block in attachments.filter(func(e): return is_instance_valid(e)):
    if "lastMovementStep" in block.root:
      root.MOVING_BLOCKS_nodeToMove.position += (block.root.lastMovementStep / root.scale).rotated(-root.rotation)
    else:
      log.err("block not moving", block.root.id)
      breakpoint

# func disableAllGroups():
#   for group in tempGroups:
#     root.remove_from_group(group)

# func enableAllGroups():
#   for group in tempGroups:
#     root.add_to_group(group)

func tryaddgroups():
  for block in get_overlapping_bodies():
    # log.pp(block, "is overlapping")
    if block.get_parent().is_in_group("canBeAttachedTo"):
      if block in attachments:
        continue
      attachments.append(block)
    # for group in block.get_parent().get_groups():
    #   if block.get_parent().is_in_group("canBeAttachedTo"):
    #     tryadd(group)
    for group in block.get_groups():
      if block in attachments:
        continue
      attachments.append(block)
      # if block.is_in_group("canBeAttachedTo"):
      #   tryadd(group)

# func tryadd(group):
#   # log.pp("trying to add", group, root.id)
#   if global.starts_with(group, "_vp_") \
#   or global.starts_with(group, "EDITOR_OPTION") \
#   or group == "respawnOnPlayerDeath" \
#   or root.is_in_group(group) \
#   or group in tempGroups \
#   : return
#   # log.pp("added", group, root.id)
#   tempGroups.append(group)
#   root.add_to_group(group)
#   # log.pp(tempGroups, group, root, root.get_groups())
