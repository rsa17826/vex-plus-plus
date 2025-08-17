extends Area2D
class_name AttachDetector

@export var root: EditorBlock

var following = true

func on_respawn():
  if not root:
    var parent = self
    while 'id' not in parent:
      parent = parent.get_parent()
    log.err("root not set", name, parent.id)
    breakpoint
  if 'canAttachToPaths' not in root.selectedOptions: return
  if 'canAttachToThings' not in root.selectedOptions: return
  if root.canAttachToPaths and root.selectedOptions.canAttachToPaths: pass
  elif root.canAttachToThings and root.selectedOptions.canAttachToThings: pass
  else: return
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

func tryaddgroups():
  for block in get_overlapping_bodies() + get_overlapping_areas():
    block = block.root
    if block == root: continue
    # if root.id == '10x spike':
    #   log.pp(block.id, root.selectedOptions.canAttachToThings, root.canAttachToThings)
    # log.pp(block, "is overlapping")
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
