@tool
@icon("res://scenes/hitbox scripts/images/attachDetector.png")
extends ShapeCast2D
class_name AttachDetector

@export var root: EditorBlock

var following = true

func _ready() -> void:
  if not Engine.is_editor_hint():
    if not global.player: return
    global.player.Alltryaddgroups.connect(tryaddgroups)
    global.hitboxTypesChanged.connect(updateColor)
  if not root:
    var parent = self
    while parent and 'id' not in parent:
      parent = parent.get_parent()
    log.err("root not set", name, parent.id)
    breakpoint
  updateColor()

func updateColor() -> void:
  visibility_layer = 1
  if Engine.is_editor_hint():
    if not global.useropts:
      global.useropts = sds.loadDataFromFile("user://main - EDITOR.sds")
    visible = false
  else:
    visible = global.useropts.showAttachDetectorHitboxes
  self.modulate = global.useropts.attachDetectorHitboxColor

func tryaddgroups():
  enabled = true
  await global.wait()
  if is_inside_tree() and is_instance_valid(self):
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