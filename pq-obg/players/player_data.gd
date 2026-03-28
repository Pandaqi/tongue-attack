extends Resource
class_name PlayerData

var players : Array[PlayerSystem] = []
var colors_available : Array[Color] = []
var colors_used : Array[Color] = []
var touch_area_layer : Control

signal reset_finished()

func reset(colors:Array[Color]) -> void:
	players = []
	colors_available = colors.duplicate()
	colors_used = []
	touch_area_layer = null
	reset_finished.emit()

func add_player(p:PlayerSystem) -> void:
	colors_used.append(colors_available.pop_front())
	players.append(p)

func remove_player(p:PlayerSystem) -> void:
	var col := get_color_for(p)
	colors_used.erase(col)
	colors_available.append(col)
	players.erase(p)

func count() -> int:
	return players.size()

func exists_at(idx:int) -> bool:
	return idx >= 0 and idx < count()

func get_from_indices(idxs:Array[int]) -> Array[PlayerSystem]:
	var arr : Array[PlayerSystem] = []
	for idx in idxs:
		if not exists_at(idx): continue
		arr.append(get_player(idx))
	return arr

func get_player(idx:int) -> PlayerSystem:
	return players[idx]

func get_player_num_for(p:PlayerSystem) -> int:
	return players.find(p)

func get_color_for(p:PlayerSystem) -> Color:
	return colors_used[get_player_num_for(p)]

func get_ratio() -> float:
	return (count() - 1) / float(Global.config_system.input_max_players_bound - 1)

func get_score_for_team(team_num:int) -> float:
	var sum := 0.0
	for player in players:
		var team := -1
		if player.has_node("ModuleStatus"):
			team = player.get_node("ModuleStatus").get_team()
		if team != team_num: continue
		
		var score := 0
		if player.has_node("ModuleScore"):
			score = player.get_node("ModuleScore").get_score()
		sum += score
	return sum
