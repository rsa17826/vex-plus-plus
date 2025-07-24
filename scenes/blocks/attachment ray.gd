extends Area2D

@export var root: EditorBlock

# var tempGroups = []
var following = true

func on_respawn():
  # root.position = Vector2.ZERO
  # disableAllGroups()
  # tempGroups = []
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
    tryaddgroups()
    await global.wait()
    tryaddgroups()
    await global.wait()
    tryaddgroups()

# func on_physics_process(delta: float) -> void:
#   if not following: return
#   for block in attachments.filter(func(e): return is_instance_valid(e)):
#     if "lastMovementStep" in block:
#       root.thingThatMoves.position += (block.lastMovementStep / root.scale).rotated(-root.rotation)
#     else:
#       log.err("block not moving", block.id)
#       breakpoint

# func disableAllGroups():
#   for group in tempGroups:
#     root.remove_from_group(group)

# func enableAllGroups():
#   for group in tempGroups:
#     root.add_to_group(group)

func tryaddgroups():
  for block in get_overlapping_bodies() + get_overlapping_areas():
    block = block.root
    # if root.id=='key':
    #   log.pp(block.id, block.is_in_group("canBeAttachedTo"))
    # log.pp(block, "is overlapping")
    if block.is_in_group("canBeAttachedTo"):
      # if not block in self parents
      if block not in root.attach_parents:
        root.attach_parents.append(block)
      # if self not in block children
      if root not in block.attach_children:
        block.attach_children.append(root)

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
