@icon("images/1.png")
extends EditorBlock
class_name BlockText

@export var label: Label
@export var sprite: Sprite2D

func generateBlockOpts():
  blockOptions.text = {"type": global.PromptTypes.string, "default": "",
    "onChange": func(newText):
      sprite.visible = !newText
      label.text = str(newText)
      return true
  }

func on_respawn():
  sprite.visible = !selectedOptions.text
  label.text = str(selectedOptions.text)
