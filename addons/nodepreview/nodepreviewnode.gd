@icon("res://rysunek-1.svg")
extends Node
class_name NodePreview

@export_enum("2D", "3D") var environment: int = 0

@export_group("Capture")

@export_group("2D Capture")

## It takes an image perfectly aligned to the sprite texture ([method Sprite2D.get_rect])
@export var capture_sprite: Sprite2D
## check [member try_to_center] If you are using TextureRect.
## It uses the rect of the box to take an image ([method TextureRect.get_rect])
@export var capture_box: TextureRect
## Basically the same as [b]Capture Box[/b] but you can enter your custom node with rect
@export var custom_capture_box: Node
## If you don't want to use node, to select an area. You can do it from the code
@export var capture_rect: Rect2i

## Select what type do you want to use. [b]Remember[/b] to set the specific capture type, so it won't result in an error
@export_enum("Sprite2D", "TextureRect", "Custom Rect", "Custom Rect Data") var capture_type: int = 0
@export_subgroup("Offset")
## If you are using anything different than sprite2D, you would probably need to turn this on.
@export var try_to_center: bool = false
## If your node has some sort of offset (Pivot offset or offset), you can apply it.
@export var use_node_pivot_offset: bool = false

@export_group("3D Capture")

enum resolutions_for_subviewport {
  VIEWPORT_SIZE,
  THE_CLOSEST_VIEWPORT_SIZE,
  CUSTOM
}

@export var use_resolution: resolutions_for_subviewport
@export var custom_3D_resolution: Vector2i = Vector2i(512, 512)
#@export var use_custom_offset: bool = false
#@export var custom_offset: Vector2

#@export_subgroup("Margins")
#@export var left_margin: int
#@export var right_margin: int
#@export var top_margin: int
#@export var bottom_margin: int

@export_group("Performance")

## from my tests only [b]UPDATE_ONCE[/b] and [b]UPDATE_ALWAYS[/b] work.[br][br]
## Try to avoid [b]UPDATE_ALWAYS[/b], it can lag your game
@export var subviewport_update_mode: SubViewport.UpdateMode = 1

## Every [method get_image] function call, will reset the image [br]
## (by setting [enum SubViewport.UpdateMode] mode [b]to Update Once[/b])
@export var update_every_call: bool = true

@export_group("SubViewport")
## optional, don't need to set it
@export var custom_subViewport: SubViewport

@export_group("Camera")
## optional, don't need to set it
@export var custom_camera_2D: Camera2D
## optional, don't need to set it
@export var custom_camera_3D: Camera3D
var nnn
func _ready() -> void:
  _make_sub_viewport()
  custom_subViewport.world_2d = get_tree().root.find_world_2d()
  if environment == 0:
    _make_camera_2D()
    _capture_box_2D()
  else:
    _make_camera_3D()
    _capture_3D()

func _capture_box_2D() -> void:
  match capture_type:
    0:
      _set_camera2D_and_viewport(capture_sprite)
    1:
      _set_camera2D_and_viewport(capture_box)
    2:
      _set_camera2D_and_viewport(custom_capture_box)
    3:
      custom_subViewport.size = capture_rect.size
      custom_camera_2D.position = capture_rect.position
      if try_to_center:
        custom_camera_2D.position += Vector2(capture_rect.size / 2)

func _capture_3D() -> void:
  match use_resolution:
    resolutions_for_subviewport.VIEWPORT_SIZE:
      custom_subViewport.size = get_tree().root.get_visible_rect().size
      log.pp(custom_subViewport.size)
    resolutions_for_subviewport.THE_CLOSEST_VIEWPORT_SIZE:
      custom_subViewport.size = get_viewport().size
    resolutions_for_subviewport.CUSTOM:
      custom_subViewport.size = custom_3D_resolution

func _set_camera2D_and_viewport(node: Node) -> void:
  if node == null:
    push_warning("[NodePreview] There is no a capture box or a sprite")
    return
  nnn = node
  custom_subViewport.size = node.sizeInPx
  custom_camera_2D.position = node.global_position
  if use_node_pivot_offset:
    custom_camera_2D.position += _try_to_get_offset(node)
  if try_to_center:
    custom_camera_2D.position.y -= (node.sizeInPx / 2).y
  log.pp("node.global_position", node.global_position, custom_camera_2D.position)

func _try_to_get_offset(node: Node) -> Vector2:
  if node.get("offset") != null: return node.get("offset")
  if node.get("pivot_offset") != null: return node.get("pivot_offset")
  return Vector2(0, 0)

func get_image() -> Image:
  if update_every_call:
    custom_subViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
  if not nnn: return
  var lastParent = nnn.get_parent()
  nnn.reparent(custom_subViewport)
  await RenderingServer.frame_post_draw
  var image: Image = custom_subViewport.get_viewport().get_texture().get_image()
  nnn.reparent(lastParent)
  return image

func _make_sub_viewport() -> void:
  if custom_subViewport != null: return
  custom_subViewport = SubViewport.new()
  custom_subViewport.transparent_bg = true
  custom_subViewport.handle_input_locally = false
  custom_subViewport.render_target_update_mode = SubViewport.UPDATE_ONCE

  add_child(custom_subViewport)

func _make_camera_2D() -> void:
  if custom_camera_2D != null:
    custom_camera_2D.reparent(custom_subViewport)
    return
  custom_camera_2D = Camera2D.new()
  custom_subViewport.add_child(custom_camera_2D)

func _make_camera_3D() -> void:
  if custom_camera_3D != null:
    custom_camera_3D.reparent(custom_subViewport)
    return
  custom_camera_3D = Camera3D.new()
  custom_subViewport.add_child(custom_camera_3D)
