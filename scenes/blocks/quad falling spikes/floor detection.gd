extends Node
@export var root: EditorBlock

func _on_body_entered(body: Node2D) -> void:
  if get_parent() in root.spikesToClone: return
  if body.root is BlockBomb:
    body.root.explode()
  get_parent().queue_free()