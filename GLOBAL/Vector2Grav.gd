class_name Vector2Grav

var vector: Vector2

var _vectorWithRot: Vector2:
  set(val):
    vector = val.rotated(global.player.defaultAngle)
    if abs(vector.x) < .001:
      vector.x = 0
    if abs(vector.y) < .001:
      vector.y = 0
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

static var ZERO: Vector2Grav:
  get():
    return Vector2Grav.new(0.0, 0.0)

static var UP: Vector2Grav:
  get():
    return Vector2Grav.new(Vector2.UP.rotated(global.player.defaultAngle))
static var DOWN: Vector2Grav:
  get():
    return Vector2Grav.new(Vector2.DOWN.rotated(global.player.defaultAngle))
static var LEFT: Vector2Grav:
  get():
    return Vector2Grav.new(Vector2.LEFT.rotated(global.player.defaultAngle))
static var RIGHT: Vector2Grav:
  get():
    return Vector2Grav.new(Vector2.RIGHT.rotated(global.player.defaultAngle))

var x:
  get():
    return _vectorWithRot.x
  set(x):
    _vectorWithRot.x = x
var y:
  get():
    return _vectorWithRot.y
  set(y):
    _vectorWithRot.y = y

# func _to_string() -> String:
#   return "Vector2Grav(" + str(x) + ", " + str(y) + ")"

func rotated(dir: float) -> Vector2Grav:
  return Vector2Grav.new(vector.rotated(dir))

func add(val: Variant) -> Vector2Grav:
  return vector + val

func eq_add(val: Variant) -> void:
  vector += val

func sub(val: Variant) -> Vector2Grav:
  return vector - val

func eq_sub(val: Variant) -> void:
  if val is Vector2Grav:
    vector -= val.vector
  elif val is Vector2:
    vector -= val

func mul(val: Variant) -> Vector2Grav:
  return vector * val

func eq_mul(val: Variant) -> void:
  vector *= val

func div(val: Variant) -> Vector2Grav:
  return vector / val

func eq_div(val: Variant) -> void:
  vector /= val

static func applyRot(x: Variant = 0.0, y: float = 0.0) -> Vector2:
  var v
  if x is Vector2:
    v = x.rotated(global.player.defaultAngle)
  else:
    v = Vector2(x, y).rotated(global.player.defaultAngle)
  return clearLow(v)

static func clearLow(v):
  if is_zero_approx(v.x): v.x = 0
  if is_zero_approx(v.y): v.y = 0
  return v
