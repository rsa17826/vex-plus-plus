extends NestedSearchable
signal onchanged()
func sort_dict_to_arr(dict):
  var temp_keys: Array = dict.keys()
  var sorted_keys = temp_keys.duplicate_deep().map(func(x): return int(x))
  sorted_keys.sort()
  var temp_vals = dict.values()
  # #log.pp(temp_keys)
  # #log.pp(temp_vals)
  # #log.pp(sorted_keys)
  var newarr = []
  for temp_key in sorted_keys:
    newarr.append([temp_key, temp_vals[temp_keys.find(temp_key)]])
  return newarr
func init(thing, menu_data, formatName, _self):
  var newarr = sort_dict_to_arr(thing.options)
  $Label.text = formatName.call(thing.name)
  $HSlider.range_min_value = newarr[0][0]
  $HSlider.range_max_value = newarr[-1][0]
  $HSlider.range_tick_count = ($HSlider.range_max_value - $HSlider.range_min_value) + 1
  $HSlider.range_step = 1
  $HSlider.range_value = float(thing.user)
  $HSlider.range_value_changed.connect(func(...__):
    onchanged.emit()
  )
  tooltip_text = thing.tooltip
