@tool
extends EditorPlugin

func _enter_tree():
  log.pp("<Log>")

func _exit_tree():
  log.pp("</Log>")
