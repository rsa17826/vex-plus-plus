class_name Vector2Grav

var vector: Vector2

var _vectorWithRot: Vector2:
  set(val):
    vector = val.rotated(global.player.defaultAngle)
  get():
    return vector.rotated(-global.player.defaultAngle)

func _init(x: Variant = 0.0, y: float = 0.0):
  if x is Vector2:
    vector = x
  elif x is Vector2Grav:
    vector = x.vector
  else:
    vector = Vector2(x, y)
  if vector:
    _vectorWithRot = vector

static var ZERO:
  get():
    return Vector2Grav.new(0.0, 0.0)

var x:
  get():
    return _vectorWithRot.x
  set(x):
    _vectorWithRot.x = x
    update()
var y:
  get():
    return _vectorWithRot.y
  set(y):
    _vectorWithRot.y = y
    update()

# func _to_string() -> String:
#   return "Vector2Grav(" + str(x) + ", " + str(y) + ")"

func update() -> void:
  # print(self)
  pass

func rotated(dir: float) -> Vector2Grav:
  return Vector2Grav.new(vector.rotated(dir))

func add(val: Variant) -> Vector2Grav:
  return vector + val

func eq_add(val: Variant) -> void:
  vector += val
  update()

func sub(val: Variant) -> Vector2Grav:
  return vector - val

func eq_sub(val: Variant) -> void:
  vector -= val
  update()

func mul(val: Variant) -> Vector2Grav:
  return vector * val

func eq_mul(val: Variant) -> void:
  vector *= val
  update()

func div(val: Variant) -> Vector2Grav:
  return vector / val

func eq_div(val: Variant) -> void:
  vector /= val
  update()

static func applyRot(x: Variant = 0.0, y: float = 0.0):
  if x is Vector2:
    return x.rotated(global.player.defaultAngle)
  else:
    return Vector2(x, y).rotated(global.player.defaultAngle)
