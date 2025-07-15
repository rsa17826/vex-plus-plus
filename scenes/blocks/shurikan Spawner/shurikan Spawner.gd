@icon("images/1.png")
extends EditorBlock
class_name BlockShurikenSpawner

@export var shurikenBase: Node2D
var shurikens = []
func on_ready():
  if !shurikens:
    for i in range(3):
      var shuriken = shurikenBase.duplicate()
      add_child(shuriken)
      hidableSprites.append(shuriken.get_node("Death"))
      collisionShapes.append(shuriken.get_node("CollisionShape2D"))
      shurikens.append(shuriken)
    shurikenBase.queue_free()
    
func on_physics_process(delta: float) -> void:
  for i in range(len(shurikens)):
    var shuriken = shurikens[i]
    var time = fmod(global.tick + (i / 1.4), 4.5)
    var pos = global.rerange(clampf(time, 0, 4), 0, 4, 0, 745.0)
    shuriken.visible = true
    shuriken.position.x = pos
    var s = 1
    if time > 4:
      s = global.rerange(time, 4, 4.5, 1, 0)
    if s <= .7:
      if !shuriken.get_node("CollisionShape2D").disabled:
        shuriken.get_node("CollisionShape2D").set_deferred("disabled", true)
    else:
      if shuriken.get_node("CollisionShape2D").disabled:
        shuriken.get_node("CollisionShape2D").set_deferred("disabled", false)
    shuriken.scale = Vector2(s, s)
    shuriken.rotation_degrees = global.rerange(time, 0, 4.5, 0, 360 * 3)
