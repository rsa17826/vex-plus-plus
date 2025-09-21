@icon("images/1.png")
extends EditorBlock
class_name BlockGlass

var broken:
  get(): return _DISABLED
  set(val):
    if val:
      __disable.call_deferred()

func onSave() -> Array[String]:
  return ["broken"]