class_name MainMenu extends CanvasLayer

@onready var button_container : VBoxContainer = $Control/CenterContainer/VBoxContainer
@export var settings : Settings

@export var play_btn : Button
@export var settings_btn : Button
@export var quit_btn : Button

@export var label_credits : Label

func _ready() -> void:
	if Global.config_system.clear_input_at_menu: Global.input.clear()
	settings.active_changed.connect(_on_settings_active_changed)
	grab_focus()
	set_icons()
	show_credits()

func show_credits() -> void:
	var string := "{game_name} · v{version} · {author}© · One Button Game".format({
		"game_name": Global.config_system.game_name,
		"version": Global.config_system.game_version,
		"author": Global.config_system.game_author
	})
	label_credits.set_text(string)

func set_icons() -> void:
	play_btn.icon = Global.config_system.icon_play
	settings_btn.icon = Global.config_system.icon_settings
	quit_btn.icon = Global.config_system.icon_quit

func grab_focus() -> void:
	button_container.get_child(0).grab_focus()

func release_focus() -> void:
	for child in button_container.get_children():
		child.release_focus()

func _on_play_pressed() -> void:
	Global.goto_game()

func _on_settings_pressed() -> void:
	set_visible(false)
	settings.set_active(true)

func _on_settings_active_changed(is_active:bool) -> void:
	if not is_active: 
		set_visible(true)
		grab_focus()
	else: release_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()
