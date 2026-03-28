extends Resource
class_name StateData

var tracker_temporary : ObjectiveTracker
var tracker_permanent : ObjectiveTracker
var final_score := 0.0 # used by custom games that just need to save a score and nothing else; much simpler

@warning_ignore("unused_signal")
signal objective_registered()

@warning_ignore("unused_signal")
signal request_paused_state(val:bool)

func reset():
	if not tracker_permanent:
		tracker_permanent = create_permanent_tracker()
	tracker_temporary = create_temporary_tracker()

func create_temporary_tracker() -> ObjectiveTracker:
	return ObjectiveTracker.new(
		Global.config_system.match_victory_type, 
		Global.config_system.match_victory_extreme, 
		Global.config_system.match_victory_metric
	)

func create_permanent_tracker() -> ObjectiveTracker:
	return ObjectiveTracker.new(
		Global.config_system.game_victory_type, 
		Global.config_system.game_victory_extreme, 
		Global.config_system.game_victory_metric
	)

func register_objective(res:ObjectiveResult) -> void:
	tracker_temporary.register_result(res)
	objective_registered.emit()

func debug_set_to_gameover() -> void:
	if not tracker_temporary:
		tracker_temporary = get_debug_tracker()
	if not tracker_permanent:
		tracker_permanent = create_permanent_tracker()

func make_temporary_results_permanent() -> void:
	var conv : Objective.VictoryConversion = Global.config_system.game_victory_conversion
	var new_results := tracker_temporary.get_results_sorted()
	
	# nothing to be done!
	if conv == Objective.VictoryConversion.NONE:
		tracker_permanent.register_results(new_results)
	
	# get a team ranking 
	# (the list is already sorted per team, per value, so just pick up the first value of each team not seen yet)
	var team_ranking = []
	for res in new_results:
		if team_ranking.has(res.get_team()): continue
		team_ranking.append(res.get_team())
	
	# the "converted rankings" are a clean way to update the overall standings correctly no matter the input or objective type
	var conv_rankings : Array[int] = []
	for i in range(new_results.size()):
		var rank := i # by default, just use our base rank of course
		
		# if we're in teams, set our individual rank to our TEAM ranking
		if tracker_temporary.metric == Objective.VictoryMetric.TEAMS:
			rank = team_ranking.find(new_results[i].get_team())
		
		# solo winner takes all, the rest on "same rank"
		if tracker_temporary.metric == Objective.VictoryMetric.SOLO_WINNER:
			rank = 0 if i == 0 else 1
		
		# solo loser misses out, the rest on "same winning rank"
		if tracker_temporary.metric == Objective.VictoryMetric.SOLO_LOSER:
			rank = 0 if (i == new_results.size() - 1) else 1
		
		conv_rankings.append(rank)
	
	# the points gained are equal to our ranking
	if conv == Objective.VictoryConversion.RANKING:
		for i in range(new_results.size()):
			new_results[i].value = conv_rankings[i] + 1
		tracker_permanent.register_results(new_results)
	
	# gain a point if on first rank, otherwise get nothing
	if conv == Objective.VictoryConversion.POINT:
		for i in range(new_results.size()):
			var has_won := (conv_rankings[i] == 0)
			new_results[i].value = 1 if has_won else 0
		tracker_permanent.register_results(new_results)

# for debugging the system or loading game over directly
func get_debug_tracker() -> ObjectiveTracker:
	var t := create_temporary_tracker()
	var buttons : Array[InputButton] = Global.input.buttons_available_all.slice(0, 3)
	t.register_results([
		ObjectiveResult.new(buttons[0].get_input_map_key(), 1000),
		ObjectiveResult.new(buttons[1].get_input_map_key(), 50000),
		ObjectiveResult.new(buttons[2].get_input_map_key(), 123456)
	])
	return t
