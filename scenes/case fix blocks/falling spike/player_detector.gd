extends RayCast2D

@export var root: EditorBlock

func _physics_process(delta: float) -> void:
  if %playerDetector.is_colliding() \
  and not root.falling \
  and not root.respawnTimer > 0 \
  and not root.respawning \
  :
    root.falling = true
    %"attach detector".following = false
    if root.selectedOptions.groupId:
      global.fallingSpikeGroupStartedFalling.emit(root.selectedOptions.groupId)

func _ready() -> void:
  global.fallingSpikeGroupStartedFalling.connect(fallingSpikeGroupStartedFalling)

func fallingSpikeGroupStartedFalling(id: int) -> void:
  if root.selectedOptions.groupId and root.selectedOptions.groupId == id:
    root.falling = true
    %"attach detector".following = false
