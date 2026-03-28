class_name Settings extends CanvasLayer

@onready var tab_container : TabContainer = $CenterContainer/VBoxContainer/TabContainer

var active := false
var all_tabs : Array[SettingTab] = []

@export var reset_btn : Button
@export var close_btn : Button

signal active_changed(ac:bool)

func _ready() -> void:
	tab_container.custom_minimum_size = Global.config_system.settings_panel_size
	collect_all_tabs()
	set_icons()
	initialize()
	visualize()
	set_active(false)

func set_icons() -> void:
	reset_btn.icon = Global.config_system.icon_reset
	reset_btn.add_theme_constant_override("icon_max_width", Global.config_system.button_font_size)
	close_btn.icon = Global.config_system.icon_quit
	close_btn.add_theme_constant_override("icon_max_width", Global.config_system.button_font_size)

func collect_all_tabs() -> void:
	all_tabs = Global.config_system.settings

func set_active(val:bool) -> void:
	active = val
	set_visible(val)
	active_changed.emit(active)
	
	# @NOTE: we need `get_tab_bar` to select the actual tabs, otherwise this just does nothing on a TabContainer => took a lot of research to figure this out!
	if active: 
		tab_container.get_tab_bar().grab_focus()

func initialize() -> void:
	for tab in all_tabs:
		tab.initialize()

func visualize() -> void:
	for tab in all_tabs:
		tab_container.add_child(tab.visualize())

func _on_close_pressed() -> void:
	set_active(false)

func _on_reset_pressed() -> void:
	for tab in all_tabs:
		tab.reset()

func _unhandled_input(ev:InputEvent) -> void:
	if not active: return
	if ev.is_action_released("ui_backward"):
		_on_close_pressed()
