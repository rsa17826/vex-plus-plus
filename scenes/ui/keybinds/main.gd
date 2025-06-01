extends Control

func _input(event: InputEvent) -> void:
  if event is InputEventKey:
    if Input.is_action_just_pressed("show_keybinds"):
      visible = !visible
      if visible:
        for c in %main.get_children():
          c.queue_free.call_deferred()
        global.loadKeybindsFromFile()
        var keybinds = global.getKeybindsFromProjectSettings()
        log.pp(keybinds)
        const keybindNode = preload("res://scenes/ui/keybinds/keybind node.tscn")
        for dictkey in keybinds:
          InputMap.action_erase_events(dictkey)
          for action in keybinds[dictkey]:
            InputMap.action_add_event(dictkey, action)
          var n = keybindNode.instantiate()
          n.keybinds = keybinds
          n.dictkey = dictkey
          log.pp(n.dictkey)
          %main.add_child(n)