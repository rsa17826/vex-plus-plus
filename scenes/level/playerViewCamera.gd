class_name PlayerViewCamera
extends Camera2D
## camera used by a split screen view, it copies the camera of the player it shows
## so all the camera logic (rotation, zoom, editor panning) stays in the player

var player: Player

func _ready() -> void:
  make_current()
func _process(_delta: float) -> void:
  # the view is removed on the next playersChanged when its player is freed
  if not global.isAlive(player): return
  global_position = player.camera.global_position
  global_rotation = player.camera.global_rotation
  zoom = player.camera.zoom
