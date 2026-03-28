extends Control
class_name ButtonInstruction 

enum Type
{
	LOGIN,
	LOGOUT
}

@export var button_visualizer : ButtonVisualizer
@export var button_container : ButtonVisualizerContainer
@export var label : Label
@export var state_data : StateData

var button : InputButton

func _ready() -> void:
	gui_input.connect(_on_input_event)
	button_container.gui_input.connect(_on_input_event)
	
	if not Global.config_system.button_instructions_panel:
		add_theme_stylebox_override("panel", StyleBoxEmpty.new())

func activate(btn: InputButton, tp:Type) -> void:
	set_type(tp)
	set_button(btn)
	refresh_size()

func refresh_size() -> void:
	var icon_size : float = Global.config_system.button_instructions_icon_size
	button_container.refresh_size(Vector2.ONE * icon_size)
	label.custom_minimum_size.y = icon_size
	label.add_theme_font_size_override("font_size", Global.config_system.button_instructions_font_size)

func set_type(tp:Type) -> void:
	if tp == Type.LOGIN:
		label.set_text("BUTTON_NEW_PLAYER")
	
	if tp == Type.LOGOUT:
		label.set_text(get_logout_text())

func get_logout_text() -> String:
	if Global.input.is_removal_type(Global.input.ButtonRemovalType.NONE):
		return "BUTTON_LOGOUT_RELOAD"
	if Global.input.is_removal_type(Global.input.ButtonRemovalType.HOLD_COND):
		return "BUTTON_LOGOUT_MODE"
	
	var time : int = ceil(Global.input.get_removal_time())
	return "{tr_1} ({time}s)".format({ tr_1 = tr("BUTTON_LOGOUT"), time = time })

func set_button(btn:InputButton) -> void:
	if not btn: 
		button_container.vis.set_button_pause()
		return
	
	button = btn
	button_container.vis.set_button(btn)

func _on_input_event(ev:InputEvent) -> void:
	var is_click := ev is InputEventScreenTouch
	if not is_click: return
	if ev.pressed: return # only trigger on RELEASE
	
	# the logout screen has no button; let it bring up the pause menu
	if not button: 
		state_data.request_paused_state.emit(true)
		return
	
	var clicks_allowed : bool = Global.config_system.allow_login_by_clicking_instruction
	if not clicks_allowed and (not button.is_touch()):
		return
	
	Global.input.request_login(button)
