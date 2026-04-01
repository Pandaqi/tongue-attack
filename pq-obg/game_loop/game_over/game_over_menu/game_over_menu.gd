extends Control
class_name GameOverMenu

@export var sub_container : VBoxContainer
@export var label_header : Label
@export var label_explanation : Label
@export var forward_btn : Button
@export var anim_player : AnimationPlayer
@export var overlay : Control

@export var audio_player : AudioStreamPlayer

func _ready():
	overlay.modulate.a = Global.config_system.ui_overlay_alpha
	process_mode = Node.PROCESS_MODE_ALWAYS
	sub_container.custom_minimum_size.x = Global.config_system.pause_menu_width
	set_visible(false)

func activate(data:GameOverDataSystem):
	set_visible(true)
	
	audio_player.stream = Global.config_system.audio_game_win if data.we_won else Global.config_system.audio_game_loss
	audio_player.play()
	
	label_header.add_theme_font_override("font", Global.theme.get_font(ThemeManager.FontType.HEADING))
	
	if data:
		label_header.text = data.get_header()
		label_explanation.text = data.get_message()

	anim_player.play("go_fade")
	
	await anim_player.animation_finished
	
	get_tree().paused = true
	forward_btn.grab_focus()

func _on_backward_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://pq-obg/game_loop/menu/menu.tscn")

func _on_forward_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
