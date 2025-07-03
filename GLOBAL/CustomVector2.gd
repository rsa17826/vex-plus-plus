class_name CustomVector2

var vector: Vector2

func _init(x: Variant = 0.0, y: float = 0.0):
  if x is Vector2:
    self.vector = x
  elif x is CustomVector2:
    self.vector = x.self.vector
  else:
    self.vector = Vector2(x, y)

static var ZERO:
  get():
    return CustomVector2.new(0.0, 0.0)

var x:
  get():
    return self.vector.x
  set(x):
    self.vector.x = x
    update()
var y:
  get():
    return self.vector.y
  set(y):
    self.vector.y = y
    update()

# func _to_string() -> String:
#   return "CustomVector2(" + str(x) + ", " + str(y) + ")"

func update() -> void:
  # print(self)
  pass

func rotated(dir: float) -> CustomVector2:
  return CustomVector2.new(self.vector.rotated(dir))

func add(val: Variant) -> CustomVector2:
  return self.vector + val

func eq_add(val: Variant) -> void:
  self.vector += val
  update()

func sub(val: Variant) -> CustomVector2:
  return self.vector - val

func eq_sub(val: Variant) -> void:
  self.vector -= val
  update()

func mul(val: Variant) -> CustomVector2:
  return self.vector * val

func eq_mul(val: Variant) -> void:
  self.vector *= val
  update()

func div(val: Variant) -> CustomVector2:
  return self.vector / val

func eq_div(val: Variant) -> void:
  self.vector /= val
  update()
