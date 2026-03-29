extends Resource
class_name ConfigData

@export var map_size := Vector2(1920, 1080)

@export var spawn_interval_bounds := Vector2(8, 3) # ~num_players
@export var spawn_num_bounds_min := Vector2(3, 6) # ~num_players
@export var spawn_num_bounds_max := Vector2(5, 16) # ~num_players

@export var all_players_have_same_desires := true
@export var num_desires_bounds_per_player := Vector2i(2,3)

@export var tongue_speed_factor := 1.0

@export var gravity_bounds := Vector2(50.0, 90.0)
@export var gravity_speed_factor := 1.0

@export var progression_factor_bounds := Vector2(1.0, 2.5)
@export var time_until_progression_at_max := 240 # ~seconds since start game

@export var score_per_correct_item := 10.0
@export var score_lost_per_missed_collectible := -10.0
@export var missed_collectible_lose_score_prob := 0.2
@export var penalty_missed_collectibles := true
@export var penalty_wrong_collectibles := false
@export var pick_up_wrong_collectibles := false

@export var max_score := 400
@export var max_score_icons := 10
@export var num_starting_score := 50
@export var max_lives := 10
@export var num_starting_lives := 6

@export var randomize_leaf_positions := false
@export var switch_leaves_if_fully_extended := true
@export var switch_leaves_vertically_on_hold := true
@export var allow_frog_hopping := false

@export var spawn_collectibles_not_in_play_prob := 0.5 # base prob at single player

@export var collectibles_remove_over_time_if_stuck := true
@export var collectibles_remove_if_stuck_duration := 3.0 # takes X seconds total of being stuck to remove
@export var collectibles_remove_alpha_min := 0.35 # lowest that an item's alpha can get before being removed

@export var narrate_desires_matched := true

@export var flying_collectibles_pattern_timer_duration := 4.0 # every X seconds, it switches between flying and standing still

@export var spawn_stones := false
@export var spawn_stone_prob := 0.03 # stones are slow and stay on screen for a while, so lower prob than you might think
@export var gravity_bounds_stone := Vector2(15.0, 35.0)
@export var size_stone := 210.0

@export var tongue_can_get_stuck := false
@export var tongue_can_stick_to_collectibles := true
@export var tongue_stuck_at_max_extension := true
@export var tongue_allow_extend_while_retracting := true
@export var tongue_can_stick_to_other_tongue := true

@export var time_needed_to_get_unstuck := 400.0 # milliseconds
@export var sticking_revive_prob := 0.33 # likelihood of getting a heart back when you stick to something and it fades away

@export var icons_enabled := true
@export var colors_enabled := true
@export var shapes_enabled := false
@export var numbers_enabled := false
@export var letters_enabled := false
