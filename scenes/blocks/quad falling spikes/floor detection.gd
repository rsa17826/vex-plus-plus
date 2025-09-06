extends Node
@export var root: EditorBlock

func _on_body_entered(body: Node2D) -> void:
  # log.err(body, name, get_parent().name)
  if body.root is BlockBomb:
    body.root.explode()
  get_parent().queue_free()