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
  var f = 'output2'
  # var a = get_editor_interface()
  # log.pp(EditorInterface.get_editor_viewport_2d())
  # add_background_video(get_editor_panel(), get_file("assets/nana7mi.ogv"))
  # var target = EditorInterface.get_editor_viewport_2d() # .get_parent()
  # var can = CanvasLayer.new()
  # can.layer = -500000000
  # target.add_child(can)
  # add_background_video(can, get_file("assets/" + f + ".ogv"))
  # add_background_image(get_editor_panel(), get_file("assets/nana7mi.png"))
  add_background_video(get_editor_panel(), load(get_file("assets/" + f + ".ogv")))
  # set_project_setting("rendering/environment/defaults/default_clear_color", Color("1a1b26ff"))

  set_project_setting("rendering/environment/defaults/default_clear_color", Color(.1, .3, .33, .5))


# extends BeautifierAPI

# var player

# func _ready() -> void:
#   set_editor_setting("interface/theme/custom_theme", get_system_file("assets/theme.tres"))
#   set_editor_setting("interface/theme/base_color", Color("0000"))
#   set_editor_setting("interface/theme/accent_color", Color("8f8fc6"))
#   set_editor_setting("interface/editor/dim_editor_on_dialog_popup", false)
#   set_editor_setting("text_editor/script_list/current_script_background_color", Color.TRANSPARENT)

#   # set_text_editor_colors_by_cfg(get_file("assets/Nana7mi.tet"))
#   # set_editor_setting("interface/theme/contrast", .15)
#   set_editor_setting("interface/theme/contrast", 0)
#   # set_text_editor_color("background_color", Color("ffffff00"))
#   EditorInterface.get_editor_viewport_2d().transparent_bg = true
#   EditorInterface.get_editor_viewport_3d(0).transparent_bg = true
#   EditorInterface.get_editor_viewport_3d(1).transparent_bg = true
#   EditorInterface.get_editor_viewport_3d(2).transparent_bg = true
#   EditorInterface.get_editor_viewport_3d(3).transparent_bg = true
#   # var filelist = [
#   #   preload("res://addons/godot_beautifier/themes/Nana7mi/assets/output8.ogv"),
#   #   preload("res://addons/godot_beautifier/themes/Nana7mi/assets/output1.ogv"),
#   # ]
#   var filelist = range(1, 11).map(func(e): return add_background_video(get_editor_panel(), load(get_file("assets/output" + str(e) + ".ogv")), false, .3))
#   log.err(filelist, 1123123123)
#   player = filelist.pick_random()
#   # var player := add_background_video(get_editor_panel(), getVid.call(), false, .3)
#   for e in filelist:
#     e.visible = false
#     e.volume = .3
#     e.stop()
#     e.finished.connect(func():
#       # if not get_window().has_focus():
#       #   await global.waituntil(func(): return get_window().has_focus())
#       var v=filelist.pick_random()
#       v.visible=true
#       v.play()
#       for n in filelist:
#         if v != n:
#           n.visible=false
#     )
#   player.visible = true
#   player.play()
#   # set_project_setting("rendering/environment/defaults/default_clear_color", Color("1a1b26ff"))

#   set_project_setting("rendering/environment/defaults/default_clear_color", Color(.1, .3, .33, .5))

# extends BeautifierAPI

# var pidx = 0

# func _ready() -> void:
#   set_editor_setting("interface/theme/custom_theme", get_system_file("assets/theme.tres"))
#   set_editor_setting("interface/theme/base_color", Color("0000"))
#   set_editor_setting("interface/theme/accent_color", Color("8f8fc6"))
#   set_editor_setting("interface/editor/dim_editor_on_dialog_popup", false)
#   set_editor_setting("text_editor/script_list/current_script_background_color", Color.TRANSPARENT)

#   # set_text_editor_colors_by_cfg(get_file("assets/Nana7mi.tet"))
#   # set_editor_setting("interface/theme/contrast", .15)
#   set_editor_setting("interface/theme/contrast", 0)
#   # set_text_editor_color("background_color", Color("ffffff00"))
#   EditorInterface.get_editor_viewport_2d().transparent_bg = true
#   EditorInterface.get_editor_viewport_3d(0).transparent_bg = true
#   EditorInterface.get_editor_viewport_3d(1).transparent_bg = true
#   EditorInterface.get_editor_viewport_3d(2).transparent_bg = true
#   EditorInterface.get_editor_viewport_3d(3).transparent_bg = true
#   # var filelist = [
#   #   preload("res://addons/godot_beautifier/themes/Nana7mi/assets/output8.ogv"),
#   #   preload("res://addons/godot_beautifier/themes/Nana7mi/assets/output1.ogv"),
#   # ]
#   var filelist = [" - Copy", "8"].map(func(e): return load(get_file("assets/output" + str(e) + ".ogv")))
#   # var filelist = range(8, 10).map(func(e): return load(get_file("assets/output" + str(e) + ".ogv")))
#   log.err(filelist, 1123123123)
#   var getVid = func getVid():
#     return filelist.pick_random()
#   var player := [add_background_video(get_editor_panel(), filelist[0], false, .3), add_background_video(get_editor_panel(), filelist[0], false, .3)]
#   log.err(player)
#   for p in player:
#     p.volume = .3
#     p.stop()
#     p.finished.connect(func():
#       # if not get_window().has_focus():
#       #   await global.waituntil(func(): return get_window().has_focus())
#       var newidx=0 if pidx else 1
#       var v=getVid.call()
#       log.pp(pidx, v)
#       # player[pidx].set_deferred('visible', false)
#       player[newidx].visible=true
#       # if player[pidx].stream != v:
#       get_tree().create_timer(1.1).timeout.connect(
#         func():
#         player[0 if pidx else 1].set_deferred('visible', false)
#         player[0 if pidx else 1].set_deferred("stream", v)
#       )
#       player[newidx].play()
#       pidx=newidx
#       )
#   player[pidx].play()
#   # set_project_setting("rendering/environment/defaults/default_clear_color", Color("1a1b26ff"))

#   set_project_setting("rendering/environment/defaults/default_clear_color", Color(.1, .3, .33, .5))