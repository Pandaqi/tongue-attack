class_name GameResult extends PanelContainer

@onready var label_result : Label = $HBoxContainer/LabelResult
@onready var label_rank : Label = $HBoxContainer/LabelRank
@onready var button_visualizer : ButtonVisualizer = $HBoxContainer/Container/ButtonVisualizer

func set_data(rank: int, res:ObjectiveResult, t:ObjectiveTracker) -> void:
	# our ranking in overall standings
	label_rank.set_text("#" + str(rank))
	
	# our specific result that brought us there (prettified to string)
	var result_string := res.get_value_as_type(t.type)
	label_result.set_text(result_string)
	
	# our button (which is our only identifying mark for players)
	# @TODO: get color too? But ... how?
	button_visualizer.set_button(Global.input.get_button_by_key(res.key))
