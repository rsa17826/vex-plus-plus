extends Camera2D
func _physics_process(delta: float) -> void:
  if global.useropts.snapCameraToPixels:
    global_transform.origin = global_transform.origin.round()


func _ready() -> void:
  global.onEditorStateChanged.connect(onEditorStateChanged)
func onEditorStateChanged():
  zoom=Vector2(1.245,1.245)*(
    global.useropts.cameraZoomInEditor
    if global.showEditorUi
    else global.useropts.cameraZoomInPlay
  )