extends CharacterBody2D

# # var collidingWithPlayer = 0

# func _physics_process(delta: float) -> void:
#   # var start = position
#   var movement = Vector2(sin(global.tick * 1.5) * 200, 0)
#   velocity = movement
#   # collidingWithPlayer -= 1
#   move_and_slide()
#   # for i in get_slide_collision_count():
#   #   var collision = get_slide_collision(i)
#   #   var block = collision.get_collider()
#     # log.pp(block, global.player)
#     # if block == global.player:
#     #   collidingWithPlayer = 2
#       # log.pp(block, collision.get_depth(), collision.get_normal())
#       # global.player.position += velocity * delta * 1.1
#       # position = start + (velocity * delta)
#       # move_and_slide()
#   # position = start + (velocity * delta)
#   # log.pp(collidingWithPlayer)
#   # if collidingWithPlayer == 1:
#   #   global.player.position += velocity * delta
# func on_respawn():
#   global_position = get_parent().startPosition