class_name InputManager extends Node

enum ButtonRemovalType
{
	HOLD, # hold the button for X seconds
	HOLD_COND, # hold the button while in "pause_mode"
	NONE, # can't log out
}

var keyboard_buttons := []
const mouse_buttons := [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]
const gamepad_buttons := [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_Y, JOY_BUTTON_X]

var buttons : Array[InputButton] = []
var buttons_available_all : Array[InputButton] = []
var buttons_available : Dictionary = {} # InputType, Array[InputButton]
var buttons_used : Array[InputButton] = []

var pause_mode := false

# set to true during gameplay, false to prevent changes during menus and stuff -> see set_active()
var open_to_input := false 

signal button_added(btn:InputButton)
signal button_removed(btn:InputButton)
signal buttons_changed()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # input management should not be locked when paused
	
	add_shared_buttons() # the keys in every game for pause/unpause/navigation
	generate_all_buttons() # fills the input map with everything
	refresh_button_selection() # only makes available what is possible/selected => preferably called on every reload/restart of the game
	Input.joy_connection_changed.connect(_on_gamepad_change)
	
	# @TODO: AAAARGH this doesn't actually work, need to do this manually
	ProjectSettings.set_setting("input_devices/pointing/emulate_touch_from_mouse", true)
	ProjectSettings.set_setting("input_devices/pointing/emulate_mouse_from_touch", true)

func set_active(val:bool) -> void:
	open_to_input = val

func set_paused(p:bool) -> void:
	pause_mode = p

# there are 2 shared buttons: the typical "go forward / go backward" combo
func add_shared_buttons() -> void:
	# "backward" is used to bring up pause menu and quit/return to menu 
	var ev_back_keyboard := InputEventKey.new()
	ev_back_keyboard.keycode = KEY_ESCAPE
	
	var ev_back_gamepad := InputEventJoypadButton.new()
	ev_back_gamepad.button_index = JOY_BUTTON_BACK
	ev_back_gamepad.device = 0
	
	var ev_back_gamepad_alt := InputEventJoypadButton.new()
	ev_back_gamepad_alt.button_index = JOY_BUTTON_START
	ev_back_gamepad_alt.device = 0
	
	InputMap.add_action("ui_backward")
	InputMap.action_add_event("ui_backward", ev_back_keyboard)
	InputMap.action_add_event("ui_backward", ev_back_gamepad)
	InputMap.action_add_event("ui_backward", ev_back_gamepad_alt)
	
	# "forward" is used to replay round or continue after pause
	var ev_keyboard := InputEventKey.new()
	ev_keyboard.keycode = KEY_SPACE
	
	var ev_gamepad := InputEventJoypadButton.new()
	ev_gamepad.button_index = JOY_BUTTON_START
	ev_gamepad.device = 0
	
	InputMap.add_action("ui_forward")
	InputMap.action_add_event("ui_forward", ev_keyboard)
	InputMap.action_add_event("ui_forward", ev_gamepad)

func generate_all_buttons() -> void:
	# KEYBOARD
	var alphabet = "abcdefghijklmnopqrstuvwxyz0123456789".split("")
	for letter in alphabet:
		keyboard_buttons.append(OS.find_keycode_from_string(letter))
	
	for button_string in keyboard_buttons:
		var btn := InputButton.new(InputButton.InputType.KEYBOARD, button_string)
		register_button(btn)
	
	# MOUSE
	for mouse_button in mouse_buttons:
		var btn := InputButton.new(InputButton.InputType.MOUSE, mouse_button)
		register_button(btn)
	
	# GAMEPADS
	for i in range(Global.config_system.input_max_gamepads):
		for gamepad_button in gamepad_buttons:
			var btn := InputButton.new(InputButton.InputType.GAMEPAD, gamepad_button, i)
			register_button(btn)
	
	# TOUCH
	for i in range(Global.config_system.input_max_touch):
		var btn := InputButton.new(InputButton.InputType.TOUCH, 0, i)
		register_button(btn)

func register_button(btn:InputButton) -> void:
	btn.add_to_input_map()
	buttons.append(btn)

func refresh_button_selection(shuffle = true) -> void:
	buttons_available = {}
	
	var types_allowed = []
	if Global.config_system.input_allow_keyboard:
		types_allowed.append(InputButton.InputType.KEYBOARD)
	if Global.config_system.input_allow_mouse:
		types_allowed.append(InputButton.InputType.MOUSE)
	if Global.config_system.input_allow_gamepad: 
		types_allowed.append(InputButton.InputType.GAMEPAD)
	if Global.config_system.input_allow_touch: 
		types_allowed.append(InputButton.InputType.TOUCH)
	
	# filter out those that aren't allowed (no matter what settings say)
	# -> gamepads not even connected
	# -> don't even have a touch screen
	var num_connected_gamepads := Input.get_connected_joypads().size()
	var has_touch_capability := DisplayServer.is_touchscreen_available()
	for btn in buttons:
		var tp := btn.type
		if not types_allowed.has(tp): continue
		
		var unconnected_gamepad := btn.type == InputButton.InputType.GAMEPAD and btn.device >= num_connected_gamepads
		if unconnected_gamepad: continue
		
		var touch_impossible := btn.type == InputButton.InputType.TOUCH and not has_touch_capability
		if touch_impossible: continue
		
		var left_mouse_bad : bool = btn.key == MOUSE_BUTTON_LEFT and (not Global.config_system.input_allow_left_mouse_button)
		if left_mouse_bad: continue
		
		if not (btn.type in buttons_available): buttons_available[tp] = []
		buttons_available[tp].append(btn)
	
	# randomize the order of them
	if shuffle:
		for type in buttons_available:
			buttons_available[type].shuffle()
	
	# save a flat list with ALL of them that never changes
	# (for checking button validity, used or not)
	buttons_available_all = []
	for key in buttons_available:
		for elem in buttons_available[key]:
			buttons_available_all.append(elem)
	
	_on_buttons_changed()

func _on_buttons_changed() -> void:
	await get_tree().process_frame
	buttons_changed.emit()

func _on_gamepad_change() -> void:
	refresh_button_selection(false)

func get_removal_time() -> float:
	return Global.config_system.input_logout_hold_duration

func get_button_by_key(key:String) -> InputButton:
	for button in buttons:
		if button.get_input_map_key() == key: return button
	return null

func get_next_button(tp:InputButton.InputType) -> InputButton:
	if not (tp in buttons_available): return null
	if is_full(): return null
	var options = buttons_available[tp]
	if options.size() <= 0: return null
	return options.front()

func grab_next_button(tp:InputButton.InputType) -> InputButton:
	var btn := get_next_button(tp)
	if not btn: return null
	grab_button(btn)
	return btn

func is_button_grabbable(btn:InputButton) -> bool:
	return buttons_available[btn.type].has(btn)

func grab_button(btn:InputButton) -> void:
	var btn_already_given_out := not is_button_grabbable(btn)
	if btn_already_given_out: return
	
	buttons_available[btn.type].erase(btn)
	buttons_used.append(btn)
	_on_buttons_changed()

func give_back_button(btn:InputButton) -> void:
	var btn_already_given_back := is_button_grabbable(btn)
	if btn_already_given_back: return
	
	buttons_used.erase(btn)
	buttons_available[btn.type].append(btn)
	_on_buttons_changed()

## It sends a signal, the PlayerSpawner responds by making the node + officially grabbing the button
func request_login(btn:InputButton) -> void:
	button_added.emit(btn)

## Same thing, it asks the PlayerSpawner to actually remove it if needed
func request_button_removal(btn:InputButton) -> void:
	button_removed.emit(btn)

func get_all_input_types() -> Array:
	return InputButton.InputType.values()

func clear() -> void:
	buttons_used = []
	refresh_button_selection()

func _unhandled_input(ev:InputEvent) -> void:
	check_new_login(ev)

func check_new_login(ev:InputEvent) -> void:
	if not open_to_input: return
	if not Global.config_system.input_login_while_playing and not pause_mode: return
	
	# check for logging in
	for type in get_all_input_types():
		var next_button := get_next_button(type)
		if not next_button: continue
		if type == InputButton.InputType.TOUCH: continue
		
		var relevant_key := next_button.get_input_map_key()
		var should_trigger := ev.is_action_released(relevant_key) if  Global.config_system.input_check_login_on_released else ev.is_action_pressed(relevant_key)
		if not should_trigger: continue
		
		request_login(next_button)

func is_full() -> bool:
	return count() >= Global.config_system.input_max_players

func count() -> int:
	return buttons_used.size()

func can_remove_button_by_hold(_button:InputButton, _time_held:float) -> bool:
	if not open_to_input: return false
	if not Global.config_system.input_logout_while_playing and not pause_mode: return false
	if is_removal_type(ButtonRemovalType.HOLD): return true
	if is_removal_type(ButtonRemovalType.HOLD_COND): return pause_mode
	return false

func is_button_possible(btn:InputButton) -> bool:
	if not btn: return true # the player was not activated yet, so don't replace their button as there's nothing to replace
	return buttons_available_all.has(btn)

func get_next_button_any() -> InputButton:
	return buttons_available_all.front()

func get_player_index(btn:InputButton) -> int:
	return buttons_used.find(btn)

func is_removal_type(tp:ButtonRemovalType) -> bool:
	return Global.config_system.input_removal_type == tp
