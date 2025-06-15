extends EditorBlock

@export_group("BOMB")
@export var blockDieArea: Area2D

func on_body_entered(body: Node):
  if body is Player:
    for block: RootIsEditorBlock in (
      blockDieArea.get_overlapping_bodies()
      + blockDieArea.get_overlapping_areas()
    ):
      block.root.__disable.call_deferred()
    __disable.call_deferred()