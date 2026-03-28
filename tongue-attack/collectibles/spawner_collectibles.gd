extends Node2D
class_name SpawnerCollectibles

@export var collectible_scene : PackedScene

@export var distance_from_edges := 256.0
@export var distance_from_top := Vector2(24.0, 48.0)

@export var timer : Timer

@export var desires : Desires 
@export var frogs : Frogs
@export var progression : Progression
@export var state : StateSystem

var collectibles : Array[Collectible] = []

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	state.game_started.connect(_on_game_started)

func _on_game_started() -> void:
	_on_timer_timeout()

func _on_timer_timeout():
	refresh(true)
	restart_timer()

func restart_timer() -> void:
	timer.stop()
	var bds := Global.config.spawn_interval_bounds
	var interval := lerpf(bds.x, bds.y, frogs.count_ratio()) / progression.get_factor()
	timer.wait_time = interval
	timer.start()

func count() -> int:
	return collectibles.size()

func get_random_position_off_screen() -> Vector2:
	var x_pos := randf_range(distance_from_edges, Global.config.map_size.x - distance_from_edges)
	var y_pos := -randf_range(distance_from_top.x, distance_from_top.y)
	#get_global_transform_with_canvas().affine_inverse() * Vector2(0)
	return Vector2(x_pos, y_pos)

func refresh(force_spawn := false) -> void:
	if frogs.count() <= 0: return
	
	var min_num_bounds := Global.config.spawn_num_bounds_min
	var max_num_bounds := Global.config.spawn_num_bounds_min
	var num_players_ratio := frogs.count_ratio()
	
	var min_num := lerpf(min_num_bounds.x, min_num_bounds.y, num_players_ratio) * progression.get_factor()
	var max_num := lerpf(max_num_bounds.x, max_num_bounds.y, num_players_ratio) * progression.get_factor()
	
	while count() < min_num:
		spawn()
	
	if force_spawn and count() < max_num:
		spawn()

# basically, with each player in the game, this probability drops until it's 0
func get_probability_spawn_uncollectible() -> float:
	return Global.config.spawn_collectibles_not_in_play_prob - 0.3 * (frogs.count() - 1)

func spawn() -> void:
	var d := desires.get_random_in_play()
	var is_out_of_play := false
	
	if randf() <= get_probability_spawn_uncollectible():
		d = desires.get_random_not_in_play()
		is_out_of_play = true
	
	var is_stone := false
	if randf() <= Global.config.spawn_stone_prob:
		is_stone = true
	
	if not d: return
	
	var c : Collectible = collectible_scene.instantiate()
	add_child(c)
	c.set_position(get_random_position_off_screen())
	c.set_type(d)
	if is_out_of_play: c.make_out_of_play()
	if is_stone: c.make_stone()
	c.killed.connect(_on_collectible_killed)
	collectibles.append(c)

func _on_collectible_killed(c:Collectible) -> void:
	collectibles.erase(c)
	
	# punish if it wasn't collected ( == went off screen)
	var wasnt_collected := (not c.collected)
	var shouldve_been_collected := c.collectible and (not c.out_of_play)
	if wasnt_collected and shouldve_been_collected:
		var lose_points := randf() <= Global.config.missed_collectible_lose_score_prob
		if lose_points: 
			progression.change_score(Global.config.score_lost_per_missed_collectible)
		else:
			progression.change_lives(-1)
	
	call_deferred("refresh")
