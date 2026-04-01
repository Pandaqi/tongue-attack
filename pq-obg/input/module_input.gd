extends Node
class_name ModuleInput 

@onready var entity = get_parent()

var holder : InputHolder
## this one is never paused or interrupted, so it's able to track your button and log you out at pause screen; we go through module_input because it knows about touchscreen areas
var holder_logout : InputHolder 
var button : InputButton
var button_visualizers : Array[ButtonVisualizer] = []
var removal_warning_enabled := false
var touch_area_scene := preload("res://pq-obg/ui/touch/input_touch_area.tscn")
var touch_area : InputTouchArea

@export var hold_time := 250.0
@export var player_data : PlayerData = preload("res://pq-obg/players/player_data.tres")
@export var num_button_visualizers := 1

signal activated(mp:ModuleInput)

signal pressed()
signal released(time_held:float)
signal quick_pressed()
signal held(time_held:float)
signal hold_started()
signal hold_ended()

signal visualizers_refreshed()

signal removal_warning_started()
signal removal_warning_ended()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func activate(new_button:InputButton) -> void:
	# if we already had a button, give it back to start afresh
	if button: Global.input.give_back_button(button)
	
	# if we're placing existing players, then we already grabbed their button 
	# so we should NOT try to do so again
	if Global.input.is_button_grabbable(new_button):
		Global.input.grab_button(new_button)
		Global.audio.play_player_change_sound()
	
	button = new_button
	
	# refresh button visualizers
	clear_button_visualizers()
	for i in range(num_button_visualizers):
		add_button_visualizer()
	
	if button.is_touch():
		create_touch_area()
	
	# the holder is responsible for timing length of button press
	if holder: remove_child(holder)
	
	holder = InputHolder.new(hold_time)
	pressed.connect(holder.start_tracking)
	released.connect(holder.stop_tracking)
	holder.held.connect(_on_button_held)
	holder.started.connect(_on_hold_started)
	holder.ended.connect(_on_hold_ended)
	add_child(holder)
	
	# the holder_logout is basically the inverse
	# it runs while in pause mode to allow logging out by holding the button
	holder_logout = InputHolder.new()
	holder_logout.held.connect(_on_logout_button_held)
	add_child(holder_logout)
	
	activated.emit(self)

func deactivate() -> void:
	Global.audio.play_player_change_sound()
	clear_touch_area()
	if not Global.input.is_button_grabbable(button):
		Global.input.give_back_button(button)

func create_touch_area() -> void:
	touch_area = touch_area_scene.instantiate()
	touch_area.pressed.connect(_on_pressed)
	touch_area.released.connect(_on_released)
	
	touch_area.set_button(button)
	touch_area.set_color(player_data.get_color_for(entity))
	
	var area_layer = player_data.touch_area_layer
	area_layer.add_area(touch_area)

func clear_touch_area() -> void:
	if not touch_area: return
	touch_area.queue_free()

func clear_button_visualizers() -> void:
	for bv in button_visualizers:
		bv.queue_free()
	button_visualizers = []

func count_visualizers() -> int:
	return button_visualizers.size()

func get_button_visualizer() -> ButtonVisualizer:
	if count_visualizers() <= 0: return null
	return button_visualizers[0]

func add_button_visualizer() -> ButtonVisualizer:
	var vis := create_button_visualizer()
	button_visualizers.append(vis)
	visualizers_refreshed.emit()
	return vis

func create_button_visualizer() -> ButtonVisualizer:
	var node = Global.config_system.button_visualizer_scene.instantiate()
	add_child(node)
	node.set_tint(player_data.get_color_for(entity))
	node.set_button(button)
	
	var s : Vector2 = Vector2.ONE * Global.config_system.button_visualizer_scale * Global.config_system.button_visualizer_scale_base
	node.set_scale(s)
	return node

func _unhandled_input(ev:InputEvent) -> void:
	if not button: return
	
	var key := button.get_input_map_key()
	if key == "": return
	
	if ev.is_action_pressed(key):
		_on_pressed()
	
	if ev.is_action_released(key):
		_on_released()

func _on_pressed() -> void:
	holder_logout.start_tracking()
	if get_tree().paused: return
	pressed.emit()

func _on_released() -> void:
	holder_logout.stop_tracking()
	if get_tree().paused: return
	
	var time_held := holder.get_time_since_press()
	if time_held < hold_time: quick_pressed.emit() 
	released.emit(time_held)

func _on_button_held(time_held:float) -> void:
	held.emit(time_held)

func _on_hold_started() -> void:
	hold_started.emit()

func _on_hold_ended(time_held:float) -> void:
	hold_ended.emit(time_held)

func _on_logout_button_held(time_held:float) -> void:
	check_for_removal(time_held)

# time durations within the (input) system are always milliseconds
# but configuration times are always seconds to make it easier on players
func check_for_removal(time_held:float) -> void:
	if not Global.input.can_remove_button_by_hold(button, time_held): return
	
	# turn warnings on/off (for "you're about to remove yourself")
	var removal_time_threshold : float = Global.input.get_removal_time() * 1000.0
	var removal_time_warning : float = 0.75*removal_time_threshold
	if not removal_warning_enabled and time_held >= removal_time_warning:
		removal_warning_started.emit()
	if removal_warning_enabled and time_held < removal_time_warning:
		removal_warning_ended.emit()
	
	# actually remove us if needed
	if time_held >= removal_time_threshold:
		Global.input.request_button_removal(button)

func get_player_index() -> int:
	return Global.input.get_player_index(button)
