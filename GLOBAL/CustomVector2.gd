class_name CustomVector2

var vector: Vector2
  # get():
  #   return vector
  # set(val):
  #   vector = val

func _init(x: Variant = 0.0, y: float = 0.0):
  if x is Vector2:
    vector = x
  elif x is CustomVector2:
    vector = x.vector
  else:
    vector = Vector2(x, y)

static var ZERO = CustomVector2.new(0.0, 0.0)

var x:
  get():
    return vector.x
  set(x):
    vector.x = x
    update()
var y:
  get():
    return vector.y
  set(y):
    vector.y = y
    update()

# func _to_string() -> String:
#   return "CustomVector2(" + str(x) + ", " + str(y) + ")"

func update() -> void:
  # print(self)
  pass

func rotated(dir: float) -> CustomVector2:
  return CustomVector2.new(vector.rotated(dir))

func add(val: Variant) -> CustomVector2:
  return CustomVector2.new(vector + val)

func eq_add(val: Variant) -> void:
  vector += val
  update()

func sub(val: Variant) -> CustomVector2:
  return CustomVector2.new(vector - val)

func eq_sub(val: Variant) -> void:
  vector -= val
  update()

func mul(val: Variant) -> CustomVector2:
  return CustomVector2.new(vector * val)

func eq_mul(val: Variant) -> void:
  vector *= val
  update()

func div(val: Variant) -> CustomVector2:
  return CustomVector2.new(vector / val)

func eq_div(val: Variant) -> void:
  vector /= val
  update()
