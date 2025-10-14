class_name Cache
var cache := {}
var _data := {}
func _init() -> void: pass
func clear() -> void:
  cache = {}
func __has(thing: Variant) -> bool:
  if "lastinp" in self._data:
    log.err("lastinp should not exist", self )
    return false
  self._data.lastinp = thing
  return thing in self.cache
func __get() -> Variant:
  if "lastinp" not in self._data:
    log.err("No lastinp", self )
    return
  var val: Variant = self.cache[ self._data.lastinp]
  self._data.erase("lastinp")
  return val
func __set(value: Variant) -> Variant:
  if "lastinp" not in self._data:
    log.err("No lastinp", self )
    return
  self.cache[ self._data.lastinp] = value
  self._data.erase("lastinp")
  return value