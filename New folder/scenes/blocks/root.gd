@icon("root.png")
extends Node2D

@export var root: EditorBlock

func _ready():
  if not root:
    log.err(root, "not set", get_parent().id, get_parent().get_parent().id)
    breakpoint