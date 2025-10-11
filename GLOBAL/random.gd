class_name Random

var baseLuck: float = 0.5
var luck: float = 0.5

var minNum: float = 0
var maxNum: float = 1

var luckImmutability: float = 1

func _init(__minNum:=0.0, __maxNum:=1.0, __luckImmutability: float = 1.0, __baseLuck:=0.5) -> void:
  self.minNum = __minNum
  self.maxNum = __maxNum
  self.luckImmutability = __luckImmutability

func next():
  var distance_to_min: float = abs(luck - 0)
  var distance_to_max: float = abs(luck - 1)
  var val: float = min(distance_to_min, distance_to_max)
  var rnum: float = clamp(randfn(luck, val), 0, 1)

  var diff = - (rnum - baseLuck)
  # log.pp(diff, rnum, luck, str(luck) + " + " + str(diff) + " = " + str(luck + diff))
  luck += diff * luckImmutability
  luck = clamp(luck, 0.0, 1.0)

  return global.rerange(rnum, 0, 1, minNum, maxNum)