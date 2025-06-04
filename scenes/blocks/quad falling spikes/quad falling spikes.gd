extends "res://scenes/blocks/editor.gd"

# var respawnTimer = 0
# const RESPAWN_TIME = 150

# func on_ready():
#   %fs.onFallStarted.connect(onFallStarted)
#   %fs2.onFallStarted.connect(onFallStarted)
#   %fs3.onFallStarted.connect(onFallStarted)
#   %fs4.onFallStarted.connect(onFallStarted)

# func onFallStarted():
#   for c in [%fs, %fs2, %fs3, %fs4]:
#     if not c.falling:
#       c.startFalling()

# func on_respawn():
#   %fs.respawn()
#   %fs2.respawn()
#   %fs3.respawn()
#   %fs4.respawn()

# func on_process(delta):
#   if respawnTimer > 0:
#     respawnTimer -= delta * 60
#     return
  
#   respawnTimer = RESPAWN_TIME
#   %AnimatedSprite2D.play()
#   for c in [%fs, %fs2, %fs3, %fs4]:
#     # c.respawn()
#     c.startFalling()

# func _on_floor_detection_body_entered(body: Node2D) -> void:
#   %fs._on_floor_detection_body_entered(self)
#   %fs2._on_floor_detection_body_entered(self)
#   %fs3._on_floor_detection_body_entered(self)
#   %fs4._on_floor_detection_body_entered(self)
