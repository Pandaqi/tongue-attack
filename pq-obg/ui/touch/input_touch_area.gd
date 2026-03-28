extends Control
class_name InputTouchArea

signal pressed()
signal released()

@export var container_sprites : Node2D
@export var container : Control
@export var label : Label
var button : InputButton
var base_alpha := 0.5

func _ready() -> void:
	container.gui_input.connect(_on_input_event)
	container.custom_minimum_size = size
	
	var base_scale := Vector2(512.0, 512.0)
	container_sprites.set_position(0.5*size)
	container_sprites.set_scale(Vector2.ONE * size / base_scale)
	
	base_alpha = Global.config_system.touch_area_alpha

func _on_input_event(ev:InputEvent) -> void:
	var is_click := ev is InputEventScreenTouch
	if not is_click: return
	
	if ev.pressed: 
		container.modulate.a = 1.0
		pressed.emit()
	else:
		container.modulate.a = base_alpha
		released.emit()

func set_color(c:Color) -> void:
	container.modulate = c
	container.modulate.a = base_alpha

func set_button(b:InputButton) -> void:
	button = b
	label.set_text(str(button.device + 1))

func get_touch_area_index() -> int:
	return button.device
