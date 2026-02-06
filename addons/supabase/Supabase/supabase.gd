@tool
extends Node

const ENVIRONMENT_VARIABLES: String = "supabase/config"

var auth: SupabaseAuth
var database: SupabaseDatabase
var realtime: SupabaseRealtime
var storage: SupabaseStorage

var debug: bool = true

var config: Dictionary = {
  "supabaseUrl": "",
  "supabaseKey": ""
}

var header: PackedStringArray = [
  "Content-Type: application/json",
  "Accept: application/json"
]

func _ready() -> void:
  await global.wait()
  config.supabaseUrl = global.useropts.supabaseUrl
  config.supabaseKey = global.useropts.supabaseKey
  load_config()
  load_nodes()

# Load all config settings from ProjectSettings
func load_config() -> void:
  if config.supabaseKey != "" and config.supabaseUrl != "": pass
  else:
    var env = ConfigFile.new()
    var err = env.load("res://addons/supabase/.env")
    if err == OK:
      for key in config.keys():
        var value: String = env.get_value('supabase/config', 'supabaseUrl', "")
        breakpoint
        if value == "":
          printerr("%s has not a valid value." % key)
        else:
          config[key] = value
    else:
      printerr("Unable to read .env file at path 'res://.env'")
  header.append("apikey: %s" % [config.supabaseKey])

func load_nodes() -> void:
  auth = SupabaseAuth.new(config, header)
  database = SupabaseDatabase.new(config, header)
  realtime = SupabaseRealtime.new(config)
  storage = SupabaseStorage.new(config)
  add_child(auth)
  add_child(database)
  add_child(realtime)
  add_child(storage)

func set_debug(debugging: bool) -> void:
  debug = debugging

func _print_debug(msg: String) -> void:
  if debug: print_debug(msg)
