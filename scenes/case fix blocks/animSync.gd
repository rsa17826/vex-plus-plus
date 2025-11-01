extends AnimatedSprite2D

var frames
var speed

@export var syncOffset: int = 0

func _ready() -> void:
  frames = sprite_frames.get_frame_count(animation)
  speed = sprite_frames.get_animation_speed(animation)

func _process(delta):
  frame = (int((global.tick) * speed) + syncOffset) % frames
