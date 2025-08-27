@icon("images/1.png")
extends EditorBlock
class_name BlockDonup

var falling := false

func on_respawn():
  falling = false