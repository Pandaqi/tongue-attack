class_name InputButton

enum InputType
{
	KEYBOARD,
	GAMEPAD,
	MOUSE,
	TOUCH,
	NONE
}

var key : int
var type : InputType
var device : int

func _init(tp:InputType, k:int, d:int = 0):
	type = tp
	key = k
	device = d

func is_none() -> bool:
	return type == InputType.NONE

func is_touch() -> bool:
	return type == InputType.TOUCH

func get_input_map_key() -> String:
	if is_touch() or is_none(): return ""
	var type_as_string : String = InputType.keys()[type]
	return "button_" + str(device) + "_" + type_as_string + "_" + str(key)

# @TODO: create a humanized/readable format for every type of input
func get_input_hint_string() -> String:
	return OS.get_keycode_string(key)

func uses_input_map() -> bool:
	return [InputType.KEYBOARD, InputType.MOUSE, InputType.GAMEPAD].has(type)

func add_to_input_map() -> void:
	if not uses_input_map(): return
	
	var map_key := get_input_map_key()
	var ev : InputEvent
	
	if type == InputType.KEYBOARD:
		ev = InputEventKey.new()
		ev.keycode = key
	
	if type == InputType.MOUSE:
		ev = InputEventMouseButton.new()
		ev.button_index = key
	
	if type == InputType.GAMEPAD:
		ev = InputEventJoypadButton.new()
		ev.button_index = key
	
	if not InputMap.has_action(map_key): InputMap.add_action(map_key)
	if InputMap.action_has_event(map_key, ev): return
	InputMap.action_add_event(map_key, ev)

func print_pretty():
	var type_as_string : String = InputType.keys()[type]
	return "button_" + str(device) + "_" + type_as_string + "_" + get_input_hint_string()
	
