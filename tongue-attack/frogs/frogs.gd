extends Node2D
class_name Frogs

@export var frog_scene : PackedScene
@export var num_debug_players := 2
@export var desires : Desires
@export var map : Map
@export var progression : Progression

@export var num_desires_bounds := Global.config.num_desires_bounds_per_player

var frogs : Array[Frog] = []

var positions_per_frog_count : Array = [
	[],
	[Vector2(0, 0.5)],
	[Vector2(0, 0.25), Vector2(1, 0.75)],
	[Vector2(0, 0.25), Vector2(1, 0.5), Vector2(0, 0.75)],
	[Vector2(0, 0.2), Vector2(1, 0.4), Vector2(0, 0.6), Vector2(1, 0.8)]
]

func _ready() -> void:
	desires.generate_all_possible()
	
	spawn_debug_players()

func count() -> int:
	return frogs.size()

## Returns 1.0 if at max players, 0.0 if at min players, and then everything in-between accordingly
func count_ratio() -> float:
	return (count() - Global.config_system.input_min_players_bound) / float(Global.config_system.input_max_players_bound - Global.config_system.input_min_players_bound)

func spawn_debug_players() -> void:
	if not OS.is_debug_build(): return
	if num_debug_players <= 0: return
	spawn_multiple(num_debug_players)

func spawn_multiple(num:int) -> void:
	for i in range(num):
		spawn()

func _on_player_spawn_requested(_btn:InputButton) -> PlayerSystem:
	return spawn()

func spawn() -> Frog:
	var f : Frog = frog_scene.instantiate()
	var num_desires := randi_range(num_desires_bounds.x, num_desires_bounds.y)
	f.module_desires.set_all(desires.get_next_desires(num_desires))
	f.place_on_leaf(map.get_next_leaf())
	f.killed.connect(_on_frog_killed)
	f.scored.connect(_on_frog_scored)
	f.lives_lost.connect(_on_frog_lives_lost)
	frogs.append(f)
	add_child(f)
	return f

func _on_frog_scored(s:float) -> void:
	progression.change_score(s)

func _on_frog_lives_lost(dl:int) -> void:
	progression.change_lives(dl)

func _on_frog_killed(f:Frog) -> void:
	frogs.erase(f)
	desires.give_back_desires(f.module_desires.get_all())
	map.give_back_leaf(f.leaf)

func refresh_positions() -> void:
	var num := frogs.size()
	var positions = positions_per_frog_count[num]
	for i in range(positions.size()):
		var pos_rel : Vector2 = positions[i]
		frogs[i].set_position(pos_rel * Global.config.map_size)
		frogs[i].set_facing_direction(Vector2.RIGHT if is_zero_approx(pos_rel.x) else Vector2.LEFT)
