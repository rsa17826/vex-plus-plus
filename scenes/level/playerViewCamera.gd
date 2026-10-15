class_name PlayerViewCamera
extends Camera2D
## camera used by a split screen view, it copies the camera of the player it shows
## so all the camera logic (rotation, zoom, editor panning) stays in the player

var player: Player

func _ready() -> void:
  # a camera ignores its own rotation by default, the player's camera doesn't
  # after the player's camera has moved for this frame
  process_priority = 100
  ignore_rotation = false
  make_current()
func _process(_delta: float) -> void:
  # the view is removed on the next playersChanged when its player is freed
  if not global.isAlive(player): return
  # the screen center includes the smoothing of the player's camera, its global_position doesn't
  global_position = player.camera.get_screen_center_position()
  global_rotation = player.camera.global_rotation
  zoom = player.camera.zoom
