@icon("images/1.png")
extends EditorBlock
class_name BlockTargetingLaser

func on_body_entered(body: Node2D) -> void:
  if body is Player:
    if self not in global.player.targetinglasers:
      global.player.targetinglasers.append(self )

func on_body_exited(body: Node2D) -> void:
  if body is Player:
    if self in global.player.targetinglasers:
      global.player.targetinglasers.erase(self )

func on_physics_process(delta: float) -> void:
  var targetAngle
  if self in global.player.targetinglasers:
    targetAngle = global.player.global_position.angle_to_point(global_position)
  else:
    targetAngle = 0
  self.rotation = lerp_angle(self.rotation, targetAngle, 0.1)