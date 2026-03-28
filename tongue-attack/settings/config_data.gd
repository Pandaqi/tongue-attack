extends Resource
class_name ConfigData

@export var map_size := Vector2(1920, 1080)

@export var spawn_interval_bounds := Vector2(5, 3) # ~num_players
@export var spawn_num_bounds_min := Vector2(4, 6) # ~num_players
@export var spawn_num_bounds_max := Vector2(8, 16) # ~num_players

@export var num_desires_bounds_per_player := Vector2i(2,3)

@export var gravity_bounds := Vector2(25.0, 100.0)


@export var progression_factor_bounds := Vector2(1.0, 5.0)
@export var time_until_progression_at_max := 180 # ~seconds since start game

@export var score_per_correct_item := 10.0
@export var score_lost_per_missed_collectible := -10.0
@export var missed_collectible_lose_score_prob := 0.5
@export var num_starting_lives := 5
