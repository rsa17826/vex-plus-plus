@abstract
extends EditorBlock
class_name BlockBigFan
var FORCE: int

var thingsInside: Array = []

func on_body_entered(body: Node2D) -> void:
  if body.root not in thingsInside:
    thingsInside.append(body.root)

func on_body_exited(body: Node2D) -> void:
  if body.root in thingsInside:
    thingsInside.erase(body.root)

func on_physics_process(delta: float) -> void:
  for thing in thingsInside:
    if thing is EditorPlayer:
      thing = thing.player
    elif thing is BlockBomb or thing is BlockPushableBox or thing is Player:
      thing = thing.thingThatMoves
    else: return
    thing.vel.wind = Vector2.RIGHT.rotated(thingThatMoves.global_rotation) * FORCE

func on_respawn():
  thingsInside.assign([])
