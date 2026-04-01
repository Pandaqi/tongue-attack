extends Node

@export var config : ConfigData
@export var config_system : ConfigSystemData

var input : InputManager
var audio : AudioManager
var theme : ThemeManager
var tween : TweenManager
var state : StateManager

enum GameLoopState
{
	LOADING,
	MENU,
	GAME,
	GAMEOVER
}

var num_plays := 0
var num_reloads := 0
var game_loop_state := GameLoopState.LOADING

@warning_ignore("unused_signal")
signal pause_mode_change()

func _enter_tree():
	audio = AudioManager.new()
	add_child(audio)
	
	state = StateManager.new()
	add_child(state)
	
	theme = ThemeManager.new()
	add_child(theme)
	
	input = InputManager.new()
	add_child(input)

	tween = TweenManager.new()
	add_child(tween)

func _ready() -> void:
	set_state(GameLoopState.MENU)

func get_game_scene() -> String:
	var game_scene : String = "res://" + Global.config_system.game_id + "/main.tscn"
	if Global.config_system.game_scene:
		game_scene = "res://" + Global.config_system.game_scene
	return game_scene

func set_state(gls:GameLoopState) -> void:
	game_loop_state = gls

func goto_menu() -> void:
	num_reloads = 0
	set_state(GameLoopState.MENU)
	get_tree().change_scene_to_file("res://pq-obg/game_loop/menu/menu.tscn")

func reload_game() -> void:
	num_reloads += 1
	set_state(GameLoopState.GAME)
	get_tree().reload_current_scene()

func goto_game() -> void:
	num_plays += 1
	set_state(GameLoopState.GAME)
	get_tree().change_scene_to_file(get_game_scene())

func goto_game_over() -> void:
	set_state(GameLoopState.GAMEOVER)
	get_tree().change_scene_to_file("res://pq-obg/game_loop/game_over/game_over.tscn")
