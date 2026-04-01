class_name StateSystem extends CanvasLayer

enum GameState
{
	PREGAME,
	GAME,
	POSTGAME
}

@export var state_data : StateData
@export var player_data : PlayerData

@export var start_game_immediately := false

@export var game_over_goes_to_new_scene := false
@export var game_over_data_default : GameOverDataSystem
@export var game_over_menu : GameOverMenu

@export var pause_menu : PauseMenu
@export var tutorial : Tutorial
@export var touch_areas : Control

var paused := false
var state := GameState.PREGAME

signal game_started()
signal game_finished()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	player_data.touch_area_layer = touch_areas
	
	state_data.reset()
	state_data.objective_registered.connect(_on_objective_registered)
	state_data.request_paused_state.connect(set_paused)
	Global.input.set_active(true)
	
	pause_menu.forward_pressed.connect(_on_forward_pressed)
	pause_menu.backward_pressed.connect(_on_backward_pressed)
	pause_menu.restart_pressed.connect(_on_restart_pressed)
	
	# @NOTE: yes, this double call is on purpose, the first call initializes everything properly
	set_paused(true)
	if OS.is_debug_build() and start_game_immediately: set_paused(false)

func _exit_tree() -> void:
	Global.input.set_active(false)

func set_paused(val:bool) -> void:
	var no_change_needed := paused == val
	if no_change_needed: return
	
	paused = val
	show()
	pause_menu.set_enabled(paused)
	tutorial.set_active(paused)
	get_tree().paused = paused
	Global.input.set_paused(paused)
	
	# if it's the first unpause, start the game
	if not paused and state == GameState.PREGAME:
		change_state(GameState.GAME)
	
	Global.pause_mode_change.emit()

func change_state(new_state:GameState) -> void:
	if state == new_state: return
	
	state = new_state
	
	if new_state == GameState.GAME:
		game_started.emit()
	
	if new_state == GameState.POSTGAME:
		game_finished.emit()

func _on_objective_registered() -> void:
	var num_players := player_data.count()
	var results_registered := state_data.tracker_temporary.count()
	var all_have_finished := results_registered >= num_players
	if not all_have_finished: return
	
	print("[State] All players finished; should go to game over")
	goto_game_over()

func goto_game_over(go := game_over_data_default) -> void:
	if state != GameState.GAME: return
	
	change_state(GameState.POSTGAME)
	
	if game_over_goes_to_new_scene:
		Global.goto_game_over()
		return
	
	game_over_menu.activate(go)

func _unhandled_input(ev:InputEvent) -> void:
	if not paused and ev.is_action_released("ui_backward"):
		set_paused(true)

func _on_backward_pressed() -> void:
	set_paused(false)
	Global.goto_menu()

func _on_forward_pressed() -> void:
	set_paused(false)

func _on_restart_pressed() -> void:
	set_paused(false)
	Global.reload_game()
