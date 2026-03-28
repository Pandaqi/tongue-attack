extends Button
class_name SettingsResetButton

func _ready() -> void:
	icon = Global.config_system.icon_reset
	add_theme_constant_override("icon_max_width", Global.config_system.label_font_size)
