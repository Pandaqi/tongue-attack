extends Control
class_name PauseMenu

@export var pause_menu_container : Control
@export var pause_menu_sub_container : VBoxContainer
@export var overlay : Control
@export var heading : Label

@export var backward_btn : Button
@export var restart_btn : Button
@export var forward_btn : Button

signal backward_pressed()
signal forward_pressed()
signal restart_pressed()

func _ready() -> void:
	overlay.modulate.a = Global.config_system.ui_overlay_alpha
	pause_menu_sub_container.custom_minimum_size.x = Global.config_system.pause_menu_width
		
	Global.input.buttons_changed.connect(_on_buttons_changed)
	_on_buttons_changed()
	
	# read the right icons for basic UI stuff
	set_icons()
	
	call_deferred("update_anchor")

func set_icons() -> void:
	backward_btn.icon = Global.config_system.icon_quit
	restart_btn.icon = Global.config_system.icon_reset
	forward_btn.icon = Global.config_system.icon_play
	
	heading.add_theme_font_override("font", Global.theme.get_font(ThemeManager.FontType.HEADING))

func _on_backward_pressed() -> void:
	backward_pressed.emit()

func _on_buttons_changed() -> void:
	# @TODO: Some feedback specifying you don't have enough players?
	forward_btn.disabled = not Global.input.has_enough_players()

func _on_forward_pressed() -> void:
	forward_pressed.emit()

func _on_restart_pressed() -> void:
	restart_pressed.emit()

func set_enabled(is_enabled: bool) -> void:
	set_visible(is_enabled)
	if is_enabled: forward_btn.grab_focus()

func update_anchor() -> void:
	# anchor the pause screen to whatever side we want
	var anchor := Global.config_system.pause_menu_anchor
	ScreenAnchorTool.set_control_node_with_offset(pause_menu_container, anchor)
