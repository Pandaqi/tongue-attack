extends Node2D
class_name Progression

@export var state : StateSystem
@export var game_over_data : GameOverData

var time_start := 0.0
var lives := 0
var score := 0

signal lives_changed(l:int)
signal lives_depleted()
signal score_changed(s:int)

func _ready() -> void:
	lives_depleted.connect(_on_lives_depleted)
	state.game_started.connect(_on_game_started)

func _on_game_started() -> void:
	time_start = Time.get_ticks_msec()
	change_score(Global.config.num_starting_score)
	change_lives(Global.config.num_starting_lives)

func get_time_elapsed() -> float:
	return (Time.get_ticks_msec() - time_start) / 1000.0

func get_ratio() -> float:
	return clampf(get_time_elapsed() / Global.config.time_until_progression_at_max, 0.0, 1.0)

func get_factor() -> float:
	return lerpf(Global.config.progression_factor_bounds.x, Global.config.progression_factor_bounds.y, get_ratio())

func change_lives(dl:int) -> void:
	lives = clampi(lives + dl, 0, Global.config.max_lives)
	lives_changed.emit(lives)
	if lives <= 0:
		lives_depleted.emit()

func _on_lives_depleted() -> void:
	goto_game_over(false)

func change_score(ds:float) -> void:
	score = clampi(roundi(score + ds), 0, Global.config.max_score)
	score_changed.emit(score)
	if score >= Global.config.max_score:
		_on_score_maximized()

func _on_score_maximized() -> void:
	goto_game_over(true)

func goto_game_over(we_won := false) -> void:
	game_over_data.we_won = we_won
	game_over_data.lives_left = lives
	game_over_data.score = score
	game_over_data.time_spent = roundi(get_time_elapsed())
	
	state.goto_game_over(game_over_data)
