class_name ObjectiveTracker

var results : Array[ObjectiveResult] = []
var type : Objective.VictoryType
var extreme : Objective.VictoryExtreme
var metric : Objective.VictoryMetric

func _init(t:Objective.VictoryType, e:Objective.VictoryExtreme, m:Objective.VictoryMetric):
	type = t
	extreme = e
	metric = m

# (I didn't use a dictionary because it isn't typed + the loose one-button-structure might otherwise add complications later)
func get_result_of_id(id:String) -> ObjectiveResult:
	for res in results:
		if res.key != id: continue
		return res
	return null

func register_results(new_results:Array[ObjectiveResult]) -> void:
	for res in new_results:
		register_result(res)

func register_result(new_result:ObjectiveResult) -> void:
	# find this person in the results
	var res := get_result_of_id(new_result.key)
	
	# register if doesn't exist yet
	var first_register := (res == null)
	if first_register:
		results.append(new_result)
		return
	
	# otherwise merge results
	res.add_result(new_result)

func get_results_sorted() -> Array[ObjectiveResult]:
	var descending := (extreme == Objective.VictoryExtreme.HIGHEST)
	var results_copy : Array[ObjectiveResult] = []
	for result in results:
		results_copy.append(result.clone())
	
	# calculate team totals, set all members to that total
	if metric == Objective.VictoryMetric.TEAMS:
		var team_totals : Dictionary = {}
		for res in results_copy:
			var team := res.get_team()
			var cur_val : float = team_totals[team] if (team in team_totals) else 0.0
			team_totals[team] = cur_val + res.value
		
		for res in results_copy:
			res.value = team_totals[res.get_team()]
	
	# sort depending on value (and Extreme setting)
	results_copy.sort_custom(func(a, b):
		if descending: return b.value < a.value
		return a.value < b.value
	)
	
	return results_copy

func count() -> int:
	return results.size()
