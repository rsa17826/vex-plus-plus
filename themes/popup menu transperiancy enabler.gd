@tool
extends Node

var tracked_text: Dictionary = {}

func _enter_tree() -> void:
  # Apply transformations to existing nodes when the scene loads
  _apply_to_all_nodes(get_tree().root)

  # Connect the node_added signal for when new nodes are added dynamically
  get_tree().node_added.connect(on_node_added)

func on_node_added(node: Node) -> void:
  if node is PopupPanel:
    if node and node.theme_type_variation == "TooltipPanel":
      node.transparent_bg = true
  # Apply themes to all nodes even if they are in a CanvasLayer
  if node is Control and node.get_parent() is CanvasLayer:
    node.theme = get_window().theme

  if !OS.has_feature("editor"): return

  if not is_instance_valid(node): return
  if "autoComplete" in node: return
  var id := node.get_instance_id()
  if id in tracked_text: return
  tracked_text[id] = {"node": node, "last": {}}

  # Cleanup when node exits
  node.tree_exited.connect(_on_node_exit.bind(node))
  setText(id)

func _apply_to_all_nodes(parent: Node) -> void:
  # Traverse all nodes under the given parent and apply the necessary transformations
  for node in parent.get_children():
    on_node_added(node) # Reuse the same logic for existing nodes
    _apply_to_all_nodes(node) # Recurse into child nodes

func _on_node_exit(node):
  tracked_text.erase(node.get_instance_id())

func _process(delta):
  # Poll nodes for changes in properties like text, tabs, etc.
  for id in tracked_text.keys():
    setText(id)
func setText(id: int):
  var entry = tracked_text[id]
  var node: Variant = entry.node
  if not is_instance_valid(node):
    tracked_text.erase(id)
    return
  # List to track which properties we need to check
  var properties_to_check = []

  # Check for "text" property
  if "text" in node:
    properties_to_check.append("text")

  # Check for "tabs" if it's a TabBar
  if node is TabBar:
    log.pp(node.tabs)
    for i in range(node.tabs):
      properties_to_check.append("tabs." + str(i) + '.title')
      properties_to_check.append("tabs." + str(i) + '.tooltip')
  if node is TextEdit or node is LineEdit or node is CodeEdit:
    if (node).editable:
      properties_to_check.erase("text")
  # Iterate over the properties and modify them if necessary
  for prop_path in properties_to_check:
    var current_value = getNested(node, prop_path)
    var last_value = entry.last[prop_path] if prop_path in entry.last else null

    # If the text or property has changed, we need to apply the transformation
    if !global.same(current_value, last_value):
      var transformed_value = OwO.owowify(current_value).replace("[/cowow]", "[/color]").replace("[cowow=", "[color=")

      # Set the transformed value back to the node (using setNested)
      setNested(node, prop_path, transformed_value)

      # Update the tracked "last" value
      # log.pp(entry.last[prop_path])
      entry.last[prop_path] = transformed_value

func getNested(obj: Variant, path: String) -> Variant:
  # log.pp(obj, path)
  for p in path.split('.'):
    if p not in obj:
      log.err(p, obj, path)
      return
    obj = obj[p]
  return obj
func setNested(obj, path, val) -> void:
  path = path.split('.')
  for p in path.slice(0, -1):
    obj = obj[p]
  obj.set(path[ - 1], val)
