extends Node2D
class_name SpawnerCollectibles

@export var collectible_scene : PackedScene

@export var distance_from_edges := 256.0
@export var distance_from_top := Vector2(32.0, 72.0)

@export var timer : Timer

@export var desires : Desires 
@export var frogs : Frogs
@export var progression : Progression
@export var state : StateSystem
@export var particles_scene : PackedScene

@export var audio_bad : AudioStreamPlayer2D

@export var spawn_position_grid_width := 92.0
var positions_available : Array[int] = []

var collectibles : Array[Collectible] = []
## uses the string HASHES from desires which should be identical for clones of the same one
var collectible_frequencies : Dictionary[String, int] = {}

func _ready() -> void:
	calculate_spawn_positions()
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

func get_spawn_area_width() -> float:
	return Global.config.map_size.x - 2*distance_from_edges

func get_spawn_grid_pos_from_real_pos(x_pos:float) -> int:
	return roundi((x_pos - distance_from_edges) / spawn_position_grid_width)

func calculate_spawn_positions() -> void:
	var arr : Array[int] = []
	var num_grid_cells := floori(get_spawn_area_width() / spawn_position_grid_width)
	for i in range(num_grid_cells):
		arr.append(i)
	positions_available = arr

func can_spawn() -> bool:
	return positions_available.size() > 0

func get_random_position_off_screen() -> Vector2:
	positions_available.shuffle()
	var x_pos : int = positions_available.pop_back()
	var y_pos := -randf_range(distance_from_top.x, distance_from_top.y)
	#get_global_transform_with_canvas().affine_inverse() * Vector2(0)
	return Vector2(distance_from_edges + x_pos * spawn_position_grid_width, y_pos)

func refresh(force_spawn := false) -> void:
	if frogs.count() <= 0: return
	if not can_spawn(): return
	
	var min_num_bounds := Global.config.spawn_num_bounds_min
	var max_num_bounds := Global.config.spawn_num_bounds_min
	var num_players_ratio := frogs.count_ratio()
	
	var min_num := lerpf(min_num_bounds.x, min_num_bounds.y, num_players_ratio) * progression.get_factor()
	var max_num := lerpf(max_num_bounds.x, max_num_bounds.y, num_players_ratio) * progression.get_factor()
	
	while count() < min_num and can_spawn():
		spawn()
	
	if force_spawn and count() < max_num:
		spawn()

# basically, with each player/more desires in the game, this probability drops until it's 0
func get_probability_spawn_not_in_play() -> float:
	var num_in_play := desires.count_in_play()
	var subtraction_value := 0.2 * clampf(num_in_play / 3.0 - 1.0, 0.0, 10.0)
	return Global.config.spawn_collectibles_not_in_play_prob - subtraction_value

func get_desires_sorted_by_frequency() -> Array[Desire]:
	var arr := desires.get_all_in_play()
	arr.sort_custom(func(a,b):
		var freq1 : int = collectible_frequencies.get(a.get_hash(), 0)
		var freq2 : int = collectible_frequencies.get(b.get_hash(), 0)
		return freq1 < freq2
	)
	return arr

func spawn() -> void:
	if not can_spawn(): return
	
	var options := get_desires_sorted_by_frequency()
	var max_pick_index = mini(3, options.size())
	var d := options[randi() % max_pick_index]
	var is_out_of_play := false
	
	var is_stone := Global.config.spawn_stones and randf() <= Global.config.spawn_stone_prob

	if randf() <= get_probability_spawn_not_in_play() or !d:
		d = desires.get_random_not_in_play()
		is_out_of_play = true

	if not d: return
	
	var c : Collectible = collectible_scene.instantiate()
	add_child(c)
	c.set_position(get_random_position_off_screen())
	c.set_type(d.clone())
	c.gravity_speed *= progression.get_factor()
	
	var desire_hash := d.get_hash()
	if not (desire_hash in collectible_frequencies): collectible_frequencies[desire_hash] = 0
	collectible_frequencies[desire_hash] += 1
	
	if is_out_of_play: c.make_out_of_play()
	if is_stone: c.make_stone()
	c.killed.connect(_on_collectible_killed)
	collectibles.append(c)

func _on_collectible_killed(c:Collectible) -> void:
	collectibles.erase(c)
	collectible_frequencies[c.desire.get_hash()] -= 1
	positions_available.append(get_spawn_grid_pos_from_real_pos(c.global_position.x))
	
	# punish if it wasn't collected ( == went off screen)
	var wasnt_collected := (not c.collected)
	var shouldve_been_collected := c.collectible and (not c.out_of_play)
	var should_give_penalty := (wasnt_collected and shouldve_been_collected) and Global.config.penalty_missed_collectibles
	if should_give_penalty:
		audio_bad.global_position = c.global_position
		AudioManager.play_audio_nice(audio_bad)
		var lose_points := randf() <= Global.config.missed_collectible_lose_score_prob
		if lose_points: 
			progression.change_score(Global.config.score_lost_per_missed_collectible)
		else:
			progression.change_lives(-1)
	
	var parts : CPUParticles2D = particles_scene.instantiate()
	parts.global_position = c.global_position
	parts.color = Color.RED if should_give_penalty else Color(255, 255, 255, 0.25)
	if c.collected: parts.color = Color.WHITE
	add_child(parts)
	
	call_deferred("refresh")
