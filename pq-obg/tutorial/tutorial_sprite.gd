extends Control
class_name TutorialSprite 

var stage : TutorialStage
var active := false

@export var texture_background : TextureRect
@export var texture_content : TextureRect

@export var label_heading : Label
@export var label_content : Label

@export var label_heading_icon : Control
@export var heading_hbox : HBoxContainer
@export var margin_container : MarginContainer
@export var margin_container_texture : MarginContainer

@export var panel_size := Vector2(412, 412)

@export var audio_player : AudioStreamPlayer
@export var timer : Timer

var backgrounds : Dictionary[TutorialStage.Type, AtlasTexture] = {
	TutorialStage.Type.OBJECTIVE: preload("res://pq-obg/tutorial/textures/tutorial_bg_objective.tres"),
	TutorialStage.Type.GAME_OVER: preload("res://pq-obg/tutorial/textures/tutorial_bg_game_over.tres"),
	TutorialStage.Type.BUTTON_PRESS: preload("res://pq-obg/tutorial/textures/tutorial_bg_button_press.tres"),
	TutorialStage.Type.BUTTON_HOLD: preload("res://pq-obg/tutorial/textures/tutorial_bg_button_hold.tres"),
	TutorialStage.Type.GAMEPLAY: preload("res://pq-obg/tutorial/textures/tutorial_bg_gameplay.tres")
}

var type_to_heading_key : Dictionary[TutorialStage.Type, String] = {
	TutorialStage.Type.OBJECTIVE: "TUT_OBJECTIVE_HEADING",
	TutorialStage.Type.GAME_OVER: "TUT_GAME_OVER_HEADING",
	TutorialStage.Type.BUTTON_PRESS: "TUT_BUTTON_PRESS_HEADING",
	TutorialStage.Type.BUTTON_HOLD: "TUT_BUTTON_HOLD_HEADING",
	TutorialStage.Type.GAMEPLAY: "TUT_GAMEPLAY_HEADING"
}

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func set_stage(s:TutorialStage) -> void:
	stage = s
	
	label_heading.add_theme_font_size_override("font_size", Global.config_system.tutorial_heading_font_size)
	label_heading.add_theme_font_override("font", Global.theme.get_font(ThemeManager.FontType.HEADING))
	
	label_heading.set_text(type_to_heading_key[stage.type])
	if stage.heading:
		label_heading.set_text(stage.heading)
	
	label_content.add_theme_font_size_override("font_size", Global.config_system.tutorial_content_font_size)
	label_content.set_text("This is an empty tutorial screen.")
	if stage.content:
		label_content.set_text(get_content_sanitized())
	
	texture_background.texture = backgrounds[stage.type]
	
	texture_content.hide()
	if stage.texture:
		texture_content.show()
		label_content.hide()
		texture_content.texture = stage.texture
	
	hide()

func get_content_sanitized() -> String:
	return stage.content.strip_edges(true, true)

func refresh_size(factor:float) -> void:
	custom_minimum_size = panel_size
	pivot_offset_ratio = Vector2(0.5, 0.5)
	scale = Vector2.ONE * factor

func appear() -> void:
	show()
	active = true
	TweenManager.play_fadein_tween(self, 0.66)
	
	if stage.audio:
		audio_player.stream = stage.audio
		audio_player.play()
	
	timer.stop()
	timer.wait_time = Global.config_system.tutorial_delay_remove
	var should_remove := timer.wait_time > 0.03
	if should_remove:
		timer.start()

func disappear() -> void:
	hide()
	active = false
	
	if audio_player.is_playing(): audio_player.stop()
	timer.stop()

func is_active() -> bool:
	return active

func _on_timer_timeout() -> void:
	if not is_active(): return
	
	var tw := TweenManager.play_fadeout_tween(self, 0.66)
	await tw.finished
	hide()
