class_name InputHolder extends Node

signal started()
signal held(time_held:float)
signal ended(time_held:float)

var input_key := ""
var delay := 0.0 # milliseconds
var prev_press_time := 0.0
var is_down := false
var is_held := false

func _init(d:float = 0.0) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	delay = d

func _unhandled_input(ev:InputEvent) -> void:
	track_key_self(ev)

## Most likely, the holder is part of ModuleInput which tracks press/release for it already
func track_key_self(ev:InputEvent) -> void:
	if input_key == "": return
	if not InputMap.has_action(input_key): return
	
	if ev.is_action_pressed(input_key):
		start_tracking()
	
	if ev.is_action_released(input_key):
		stop_tracking(0.0)

func start_tracking() -> void:
	prev_press_time = Time.get_ticks_msec()
	is_down = true
	is_held = false

func hold() -> void:
	is_held = true
	started.emit()

func stop_tracking(_time_held_raw:= 0.0) -> void:
	is_down = false
	is_held = false
	ended.emit(get_time_held())

func get_time_since_press() -> float:
	if not is_down: return 0
	return Time.get_ticks_msec() - prev_press_time

func get_time_held() -> float:
	return maxf(get_time_since_press() - delay, 0)

func _process(_dt:float) -> void:
	if not is_down: return
	
	if is_held:
		held.emit(get_time_held())
		return
	
	var should_hold := get_time_since_press() >= delay
	if not should_hold: return
	hold()
