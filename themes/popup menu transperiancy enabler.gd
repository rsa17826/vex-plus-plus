extends Node

func _enter_tree() -> void:
  get_tree().node_added.connect(on_node_added)

func on_node_added(node: Node) -> void:
  if node is PopupPanel:
    if node and node.theme_type_variation == "TooltipPanel":
      node.transparent_bg = true
  # apply themes to all nodes even if they are in a canvas layer
  if node is Control and node.get_parent() is CanvasLayer:
    node.theme = get_window().theme
