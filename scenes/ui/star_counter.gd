extends Label

func _process(delta):
  var collected: int = 0
  # var uncollected: int = 0
  var starCount: int = 0
  var level = global.currentLevel()
  if "star" in level.blockSaveData:
    var stars: Dictionary = level.blockSaveData.star
    starCount = len(stars)
    for i in stars:
      if stars[i].collected:
        collected += 1
      # else:
      #   uncollected += 1
  else:
    collected = 0
    starCount = len(global.level.get_node("blocks").get_children().filter(func(e): return e.id == "star"))
  text = "STARS COLLECTED: " + str(collected) + "/" + str(starCount)