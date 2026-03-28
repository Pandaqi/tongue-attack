extends Node2D
class_name Progression

@export var state : StateSystem

var time_start := 0.0
var lives := 0
var score := 0

signal lives_changed(l:int)
signal lives_depleted()
signal score_changed(s:int)

func _ready() -> void:
	time_start = Time.get_ticks_msec()
	lives_depleted.connect(_on_lives_depleted)
	await get_tree().process_frame
	change_score(0.0)
	change_lives(Global.config.num_starting_lives)

func get_time_elapsed() -> float:
	return (Time.get_ticks_msec() - time_start) / 1000.0

func get_ratio() -> float:
	return clampf(get_time_elapsed() / Global.config.time_until_progression_at_max, 0.0, 1.0)

func get_factor() -> float:
	return lerpf(Global.config.progression_factor_bounds.x, Global.config.progression_factor_bounds.y, get_ratio())

func change_lives(dl:int) -> void:
	lives = clampi(lives + dl, 0, 19)
	lives_changed.emit(lives)
	if lives <= 0:
		lives_depleted.emit()

func _on_lives_depleted() -> void:
	state.goto_game_over()

func change_score(ds:float) -> void:
	score = clampi(roundi(score + ds), 0, 9999)
	score_changed.emit(score)
