extends Node

@export var config : ConfigData
@export var config_system : ConfigSystemData

var input : InputManager
var audio : AudioManager
var theme : ThemeManager
var tween : TweenManager
var state : StateManager

@warning_ignore("unused_signal")
signal pause_mode_change()

func _ready():
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
