class_name GameResultList extends VBoxContainer

@export var game_result_scene : PackedScene
var result_nodes : Array[GameResult] = []

func show_tracker(t:ObjectiveTracker) -> void:
	var sorted_final = t.get_results_sorted()
	for i in range(sorted_final.size()):
		var node : GameResult = game_result_scene.instantiate()
		add_child(node)
		result_nodes.append(node)
		node.set_data(i, sorted_final[i], t)
