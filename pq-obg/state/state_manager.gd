extends Node
class_name StateManager

@export var settings_tabs_custom : Array[SettingTab]
@export var auto_load_settings := true
@export var save_file_name := "savegame.save"

@export var config_file_name := "settings.cfg"
const FALLBACK := "%UNSET%"
var config : ConfigFile

func _ready() -> void:
	config = ConfigFile.new()
	config.load(get_config_path())
	
	auto_load_settings = not Global.config_system.settings_only_load_through_menu
	if auto_load_settings: load_settings()

func get_config_path() -> String:
	return "user://" + config_file_name

func save_value(s:Setting) -> void:
	config.set_value(s.section, s.key, s.value)
	config.save(get_config_path())

func is_value_unset(v:Variant) -> bool:
	return (v is String and v == FALLBACK)

func read_default_value(s:Setting, val:Variant = FALLBACK) -> Variant:
	# try the global Config or ConfigShared
	if is_value_unset(val) and (s.key in Global.config):
		val = Global.config[s.key]
	
	if is_value_unset(val) and (s.key in Global.config_system):
		val = Global.config_system[s.key]
	
	# if still nothing, use default
	if is_value_unset(val):
		val = s.get_default()
	
	return val

func read_value(s:Setting) -> Variant:
	# try saved ConfigFile first; fallback is not NULL because then the errors/warning complain about no default value
	var val = config.get_value(s.section, s.key, FALLBACK)
	val = read_default_value(s, val)
	return val

func get_save_path() -> String:
	return "user://" + save_file_name

func load_settings() -> void:
	var all_tabs : Array[SettingTab] = Global.config_system.settings
	if settings_tabs_custom.size() > 0:
		all_tabs = settings_tabs_custom
	
	for tab in all_tabs:
		tab.initialize()

func save_save_data(data:Dictionary) -> void:
	var save_file = FileAccess.open(get_save_path(), FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)

func load_save_data() -> Dictionary:
	var save_file = FileAccess.open(get_save_path(), FileAccess.READ)
	var json := JSON.new()
	json.parse(save_file)
	return json.data
