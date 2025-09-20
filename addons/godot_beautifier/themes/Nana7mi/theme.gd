extends BeautifierAPI

func _ready() -> void:
  set_editor_setting("interface/theme/custom_theme", get_system_file("assets/theme.tres"))
  set_editor_setting("interface/theme/base_color", Color("0000"))
  set_editor_setting("interface/theme/accent_color", Color("8f8fc6"))
  set_editor_setting("interface/editor/dim_editor_on_dialog_popup", false)
  set_editor_setting("text_editor/script_list/current_script_background_color", Color.TRANSPARENT)

  # set_text_editor_colors_by_cfg(get_file("assets/Nana7mi.tet"))
  # set_editor_setting("interface/theme/contrast", .15)
  set_editor_setting("interface/theme/contrast", 0)
  # set_text_editor_color("background_color", Color("ffffff00"))
  EditorInterface.get_editor_viewport_2d().transparent_bg = true
  EditorInterface.get_editor_viewport_3d(0).transparent_bg = true
  EditorInterface.get_editor_viewport_3d(1).transparent_bg = true
  EditorInterface.get_editor_viewport_3d(2).transparent_bg = true
  EditorInterface.get_editor_viewport_3d(3).transparent_bg = true
  var f = 'output'
  # var a = get_editor_interface()
  # log.pp(EditorInterface.get_editor_viewport_2d())
  # add_background_video(get_editor_panel(), get_file("assets/nana7mi.ogv"))
  # var target = EditorInterface.get_editor_viewport_2d() # .get_parent()
  # var can = CanvasLayer.new()
  # can.layer = -500000000
  # target.add_child(can)
  # add_background_video(can, get_file("assets/" + f + ".ogv"))
  # add_background_image(get_editor_panel(), get_file("assets/nana7mi.png"))
  add_background_video(get_editor_panel(), get_file("assets/" + f + ".ogv"))
  # set_project_setting("rendering/environment/defaults/default_clear_color", Color("1a1b26ff"))

  set_project_setting("rendering/environment/defaults/default_clear_color", Color(.1, .3, .33, .5))