extends Node2D
class_name Desires

## desires that are not currently owned by anyone
var desires_available : Array[Desire] = []

## desires that are currently owned by someone
var desires_in_play : Array[Desire] = []

## the possible desire templates
@export var desire_types : Array[DesireType] = []

func has_none_available() -> bool:
	return desires_available.size() <= 0

func is_desire_type_enabled(key:String) -> bool:
	return Global.config[key + "_enabled"] == true

func generate_all_possible() -> void:
	var arr : Array[Desire] = []
	for desire_type in desire_types:
		if not is_desire_type_enabled(desire_type.key): continue
		for type_value in desire_type.get_all_types():
			arr.append(Desire.new(desire_type, type_value))
	desires_available = arr
	desires_available.shuffle()

func get_random_not_in_play() -> Desire:
	if desires_available.size() <= 0: return null
	return desires_available.pick_random()

func get_random_in_play() -> Desire:
	if desires_in_play.size() <= 0: return null
	return desires_in_play.pick_random()

func get_next_desire() -> Desire:
	if has_none_available(): return null
	var d : Desire = desires_available.pop_back()
	desires_in_play.append(d)
	return d

func get_next_desires(num:int) -> Array[Desire]:
	var arr : Array[Desire] = []
	for i in range(num):
		arr.append(get_next_desire())
	return arr

func give_back_desires(arr:Array[Desire]) -> void:
	for elem in arr:
		desires_in_play.erase(arr)
		desires_available.append(arr)
	desires_available.shuffle()
