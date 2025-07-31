@icon("images/editorBar.png")
extends EditorBlock
class_name BlockUndeath

# func on_body_entered(body: Node2D) -> void:
#   if global.player.state == global.player.States.dead and not global.player.lastDeathWasForced:
#     global.player.stopDying()
#     var top = thingThatMoves.global_position.y - (sizeInPx.y / 2) - 16.5
#     var left = thingThatMoves.global_position.x - (sizeInPx.x / 2) - 4
#     var right = thingThatMoves.global_position.x + (sizeInPx.x / 2) + 4
#     var bottom = thingThatMoves.global_position.y + (sizeInPx.y / 2) + 16.5
#     var pos = global.player.global_position

#     # Calculate distances to edges
#     var dist_left = abs(pos.x - left)
#     var dist_right = abs(pos.x - right)
#     var dist_top = abs(pos.y - top)
#     var dist_bottom = abs(pos.y - bottom)

#     # Determine closest edge
#     var closest_edge = min(dist_left, min(dist_right, min(dist_top, dist_bottom)))

#     # Snap player to closest edge
#     if closest_edge == dist_left:
#       global.player.global_position.x = left
#     elif closest_edge == dist_right:
#       global.player.global_position.x = right
#     elif closest_edge == dist_top:
#       global.player.global_position.y = top
#     elif closest_edge == dist_bottom:
#       global.player.global_position.y = bottom
#   # else:
#   #   if not self in global.player.shouldStopDying:
#   #     global.player.shouldStopDying.append(self )
# # func on_body_exited(body: Node2D) -> void:
# #   if self in global.player.shouldStopDying:
# #     global.player.shouldStopDying.erase(self )
