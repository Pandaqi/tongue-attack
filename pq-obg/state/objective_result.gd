class_name ObjectiveResult

var key:String
var value:float
var team:int = -1
var metadata:Dictionary = {} # any custom stuff the game wants to save about the player

func _init(k:String, v:float) -> void:
	self.key = k
	self.value = v

func clone() -> ObjectiveResult:
	var o := ObjectiveResult.new(key, value)
	o.team = team
	o.metadata = metadata
	return o

func add_result(res:ObjectiveResult) -> void:
	value += res.value

func get_team() -> int:
	return team

# when your score is something like "games won" or "goals scored"
func get_discrete() -> int:
	return roundi(value)

# when your score is a time-related task
func get_as_time() -> String:
	var minutes = floori(value / 1000.0 / 60.0)
	if minutes < 10:
		minutes = "0" + str(minutes)
	
	var seconds = floori(value / 1000.0)
	if seconds < 10:
		seconds = "0" + str(seconds)
	
	var milliseconds = floori((value - floori(value)) / 100.0) # only display first 2 digits
	if milliseconds < 10:
		milliseconds = "0" + str(milliseconds)
	
	return str(minutes) + ":" + str(seconds) + ":" + str(milliseconds)

func get_value_as_type(tp:Objective.VictoryType) -> String:
	if tp == Objective.VictoryType.TIME: return get_as_time()
	if tp == Objective.VictoryType.DISCRETE: return str(get_discrete())
	return str(value)
