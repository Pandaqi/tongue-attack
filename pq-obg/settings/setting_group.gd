extends Resource
class_name SettingGroup

@export var settings : Array[Setting] = []
@export var label : String = "group"

func set_label(l:String) -> SettingGroup:
	label = l
	return self

func add(s:Setting) -> void:
	settings.append(s)

func initialize() -> void:
	for setting in settings:
		setting.section = label
		setting.initialize()

func reset() -> void:
	for setting in settings:
		setting.reset()

func visualize() -> PanelContainer:
	var cont := PanelContainer.new()
	cont.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#cont.add_theme_stylebox_override("panel", res)
	
	var vbox := VBoxContainer.new()
	cont.add_child(vbox)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var heading := Label.new()
	vbox.add_child(heading)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", Global.theme.get_font(ThemeManager.FontType.HEADING))
	heading.set_text(label)
	
	for setting in settings:
		vbox.add_child(setting.visualize())
	
	return cont
