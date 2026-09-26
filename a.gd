@tool
extends EditorScript

const ROOT_FOLDER := "res://themes/pompi"

func _run() -> void:
  var files := get_tres_files(ROOT_FOLDER)

  for path in files:
    var resource = load(path)

    if resource is Theme:
      uniquify_theme(resource)
      var error := ResourceSaver.save(resource, path)

      if error == OK:
        log.pp("Uniquified: ", path)
      else:
        push_error("Could not save: %s, error %s" % [path, error])

func get_tres_files(folder_path: String) -> Array[String]:
  var result: Array[String] = []
  var directory := DirAccess.open(folder_path)

  if directory == null:
    return result

  directory.list_dir_begin()

  while true:
    var file_name := directory.get_next()

    if file_name == "": break

    if file_name == "." or file_name == "..": continue

    var full_path := folder_path.path_join(file_name)

    if directory.current_is_dir():
      result.append_array(get_tres_files(full_path))
    elif file_name.ends_with(".tres"):
      result.append(full_path)

  directory.list_dir_end()
  return result

func uniquify_theme(theme: Theme) -> void:
  # StyleBox resources
  for theme_type in theme.get_stylebox_type_list():
    for item_name in theme.get_stylebox_list(theme_type):
      var stylebox := theme.get_stylebox(item_name, theme_type)

      if stylebox:
        theme.set_stylebox(
          item_name,
          theme_type,
          stylebox.duplicate(true)
        )

  # Icon resources
  for theme_type in theme.get_icon_type_list():
    for item_name in theme.get_icon_list(theme_type):
      var icon := theme.get_icon(item_name, theme_type)

      if icon:
        theme.set_icon(
          item_name,
          theme_type,
          icon.duplicate(true)
        )

  # Font resources
  for theme_type in theme.get_font_type_list():
    for item_name in theme.get_font_list(theme_type):
      var font := theme.get_font(item_name, theme_type)

      if font:
        theme.set_font(
          item_name,
          theme_type,
          font.duplicate(true)
        )

  # Font-size values are integers, so there is nothing to duplicate.
