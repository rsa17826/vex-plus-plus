# res://globals.gd added as an autoload

extends Node


func _ready() -> void:
    EngineDebugger.register_message_capture("tile-instances", _on_tile_instances)
    EngineDebugger.send_message.call_deferred("tile-instances:get_id", [])


func _on_tile_instances(message:String, data:Array) -> bool:
    match message:
        "session_id":
            var info:Dictionary = data[0]
            var id = info.get("id", -1)
            var all = info.get("all", [])
            print(info)
            if all.size() > 1:
                for i in all.size():
                    var other = all[i]
                    if other == id:
                        tile_window(i, all.size())

            return true

    return false


func tile_window(i:int, total:int) -> void:
    var window = get_window()
    var screen = window.current_screen
    var screen_rect = DisplayServer.screen_get_usable_rect(screen)
    var window_rect = window.get_visible_rect()
    printt(window_rect, screen_rect)
    match total:
        2:
            window.position.x = (screen_rect.size.x / 2 - window_rect.size.x / 2)
            window.position.y = (screen_rect.size.y / 2 - window_rect.size.y / 2)
            if i == 0:
                window.position.x -= window_rect.size.x / 2 + 16
            else:
                window.position.x += window_rect.size.x / 2 + 16
        3:
            pass
        4:
            pass