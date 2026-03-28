class_name TimeTracker extends Node

var start_time : float = -1
var end_time : float = -1
var modifier := 0.0 # used by custom powerups
var scalar := 1.0 # used by custom powerups

func is_valid() -> bool:
	return start_time >= 0.0 and end_time >= 0.0

func start_tracking() -> void:
	start_time = Time.get_ticks_msec()

func stop_tracking() -> void:
	end_time = Time.get_ticks_msec()

func get_time_elapsed(use_raw = false) -> float:
	var time_raw := end_time - start_time
	if end_time < 0: time_raw = Time.get_ticks_msec() - start_time
	if use_raw: return time_raw
	var time_final = (time_raw + modifier) * scalar
	return time_final

func change_modifier(m:float) -> void:
	modifier += m

func change_scalar(s:float) -> void:
	scalar *= s
