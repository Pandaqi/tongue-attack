extends Node2D
class_name ButtonVisualizer 

var button : InputButton

const PAUSE_FRAME := 13
const FRAMES : Dictionary[InputButton.InputType, int] = {
	InputButton.InputType.KEYBOARD: 0,
	InputButton.InputType.MOUSE: 1,
	InputButton.InputType.GAMEPAD: 2,
	InputButton.InputType.TOUCH: 12,
}

@export var sprite_ui : Sprite2D

@export var keyboard_label : Label
@export var gamepad_label : Label
@export var touch_label : Label

@export var sub_sprites : Node2D

@export var mouse_left : Sprite2D
@export var mouse_right : Sprite2D
@export var mouse_middle : Sprite2D

@export var gamepad_left : Sprite2D
@export var gamepad_right : Sprite2D
@export var gamepad_top : Sprite2D
@export var gamepad_bottom : Sprite2D

@export var tint_color_highlight := Color(1,0,0)
@export var tint_color_bg := Color(1,1,1)

func hide_all() -> void:
	sprite_ui.hide()
	for sprite in sub_sprites.get_children():
		sprite.set_visible(false)
		keyboard_label.set_visible(false)
	gamepad_label.set_visible(false)
	touch_label.set_visible(false)

func set_button_pause() -> void:
	hide_all()
	sprite_ui.show()
	sprite_ui.set_frame(PAUSE_FRAME)

func set_button(btn:InputButton) -> void:
	button = btn
	
	# first hide all sprites; we'll enable only the ones we need
	hide_all()
	
	# background UI per type
	sprite_ui.show()
	sprite_ui.set_frame(get_frame())
	sprite_ui.modulate = tint_color_bg
	
	# just using dictionaries for much cleaner loop after it
	var MOUSE_BUTTONS_TO_NODES : Dictionary[int,Node2D] = {
		MOUSE_BUTTON_LEFT: mouse_left,
		MOUSE_BUTTON_MIDDLE: mouse_middle,
		MOUSE_BUTTON_RIGHT: mouse_right
	}
	
	var GAMEPAD_BUTTONS_TO_NODES : Dictionary[int,Node2D] = {
		JOY_BUTTON_Y: gamepad_top,
		JOY_BUTTON_A: gamepad_right,
		JOY_BUTTON_B: gamepad_bottom,
		JOY_BUTTON_X: gamepad_left
	}
	
	# then only show+tint the relevant one(s)
	if is_mouse():
		var mouse_node := MOUSE_BUTTONS_TO_NODES[btn.key]
		mouse_node.set_visible(true)
		mouse_node.modulate = tint_color_highlight
	
	if is_gamepad():
		var gamepad_node := GAMEPAD_BUTTONS_TO_NODES[btn.key]
		gamepad_node.set_visible(true)
		gamepad_node.modulate = tint_color_highlight
	
	# show exact keyboard button (if needed) => special case because it needs text, so not a "SubSprite"
	keyboard_label.set_visible(is_keyboard())
	keyboard_label.set_text(btn.get_input_hint_string())
	
	# show exact gamepad device (if needed)
	gamepad_label.set_visible(is_gamepad())
	gamepad_label.set_text(str(btn.device + 1))
	
	# same with touch "devices" (which just count which area you're using)
	touch_label.set_visible(is_touch())
	touch_label.set_text(str(btn.device + 1))

func is_keyboard() -> bool:
	return button.type == InputButton.InputType.KEYBOARD

func is_mouse() -> bool:
	return button.type == InputButton.InputType.MOUSE

func is_gamepad() -> bool:
	return button.type == InputButton.InputType.GAMEPAD

func is_touch() -> bool:
	return button.type == InputButton.InputType.TOUCH

func set_tint(c:Color) -> void:
	tint_color_bg = c

func get_frame() -> int:
	return FRAMES[button.type]
