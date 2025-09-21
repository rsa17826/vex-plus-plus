@icon("res://scenes/hitbox scripts/images/attachDetector.png")
extends ShapeCast2D
class_name AttachDetector

@export var root: EditorBlock

var following = true

func _ready() -> void:
  global.player.Alltryaddgroups.connect(tryaddgroups)

# func on_respawn():
#   if not root:
#     var parent = self
#     while 'id' not in parent:
#       parent = parent.get_parent()
#     log.err("root not set", name, parent.id)
#     breakpoint
#   if root.canAttachToPaths:
#     if not ('canAttachToPaths' in root.selectedOptions):
#       log.warn('canAttachToPaths', root.id)
#       return
#   if root.canAttachToThings:
#     if not ('canAttachToThings' in root.selectedOptions):
#       log.warn('canAttachToThings', root.id)
#       return
#   if root.canAttachToPaths and root.selectedOptions.canAttachToPaths: pass
#   elif root.canAttachToThings and root.selectedOptions.canAttachToThings: pass
#   else: return
#   following = true
#   var i = 0
#   await global.wait()
#   await global.wait()
#   while i < 6:
#     i += 1
#     await global.wait()
#     tryaddgroups()

func tryaddgroups():
  enabled = true
  force_shapecast_update()
  enabled = false
  for i in range(get_collision_count()):
    var block := get_collider(i)
    block = block.root
    if block == root: continue
    if (
      root.canAttachToThings
      and root.selectedOptions.canAttachToThings
      and not (block is BlockPath)
    ) \
    or (
      root.canAttachToPaths
      and root.selectedOptions.canAttachToPaths
      and block is BlockPath
    ):
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
