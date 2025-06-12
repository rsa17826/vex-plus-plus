extends "res://scenes/blocks/editor.gd"

@export_group("FALLING")

var falling := false

func on_respawn():
  falling = false