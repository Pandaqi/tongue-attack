extends Control
class_name TutorialSprite 

var stage : TutorialStage

@export var texture_background : TextureRect
@export var texture_content : TextureRect

@export var label_heading : Label
@export var label_content : Label

@export var label_heading_icon : Control
@export var heading_hbox : HBoxContainer
@export var margin_container : MarginContainer
@export var margin_container_texture : MarginContainer

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
		label_content.set_text(stage.content)
	
	texture_background.texture = backgrounds[stage.type]
	
	texture_content.hide()
	if stage.texture:
		texture_content.show()
		label_content.hide()
		texture_content.texture = stage.texture
	
	hide()

func refresh_size(factor:float) -> void:
	# @NOTE: the base size for all these values is 256,256---but that doesn't matter here now
	label_heading_icon.custom_minimum_size.x = factor * 48.0
	heading_hbox.add_theme_constant_override("separation", int(factor * 24.0))
	heading_hbox.custom_minimum_size.y = factor * 42.0
	
	# the container that has the whole thing
	var m : int = int(factor * 8.0)
	margin_container.add_theme_constant_override("margin_left", m)
	margin_container.add_theme_constant_override("margin_right", m)
	margin_container.add_theme_constant_override("margin_top", m)
	margin_container.add_theme_constant_override("margin_bottom", int((20/8.0) * m))
	
	# the container that has the tutorial texture
	var mt : int = int(factor * 16.0)
	margin_container_texture.add_theme_constant_override("margin_left", mt)
	margin_container_texture.add_theme_constant_override("margin_right", mt)
	margin_container_texture.add_theme_constant_override("margin_top", mt)
	margin_container_texture.add_theme_constant_override("margin_bottom", mt)

func appear() -> void:
	show()
	Global.tween.play_fadein_tween(self, 0.66)
	
	timer.stop()
	timer.wait_time = Global.config_system.tutorial_delay_remove
	var should_remove := timer.wait_time > 0.03
	if should_remove:
		timer.start()

func _on_timer_timeout() -> void:
	var tw := Global.tween.play_fadeout_tween(self, 0.66)
	await tw.finished
	hide()
