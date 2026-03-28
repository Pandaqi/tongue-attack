extends Node2D
class_name SpawnerCollectibles

@export var collectible_scene : PackedScene

@export var distance_from_edges := 256.0
@export var distance_from_top := 32.0

@export var timer : Timer

@export var desires : Desires 
@export var frogs : Frogs
@export var progression : Progression

var collectibles : Array[Collectible] = []

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
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
	var y_pos := -distance_from_top
	#get_global_transform_with_canvas().affine_inverse() * Vector2(0)
	return Vector2(x_pos, y_pos)

func refresh(force_spawn := false) -> void:
	var min_num_bounds := Global.config.spawn_num_bounds_min
	var max_num_bounds := Global.config.spawn_num_bounds_min
	var num_players_ratio := frogs.count_ratio()
	
	var min_num := lerpf(min_num_bounds.x, min_num_bounds.y, num_players_ratio) * progression.get_factor()
	var max_num := lerpf(max_num_bounds.x, max_num_bounds.y, num_players_ratio) * progression.get_factor()
	
	while count() < min_num:
		spawn()
	
	if force_spawn and count() < max_num:
		spawn()

func spawn() -> void:
	var c : Collectible = collectible_scene.instantiate()
	add_child(c)
	c.set_position(get_random_position_off_screen())
	c.set_type(desires.get_random_in_play())
	c.killed.connect(_on_collectible_killed)
	collectibles.append(c)

func _on_collectible_killed(c:Collectible) -> void:
	collectibles.erase(c)
	
	var lose_points := randf() <= Global.config.missed_collectible_lose_score_prob
	if lose_points: 
		progression.change_score(Global.config.score_lost_per_missed_collectible)
	else:
		progression.change_lives(-1)
	
	call_deferred("refresh")
