extends Resource
class_name SettingTab

@export var groups : Array[SettingGroup] = []
@export var label : String

func set_label(l:String) -> SettingTab:
	label = l
	return self

func add(s:SettingGroup) -> void:
	groups.append(s)

func initialize() -> void:
	for group in groups:
		group.initialize()

func reset() -> void:
	for group in groups:
		group.reset()

func visualize() -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.name = label # @NOTE: that name is used for the tab names in TabContainer parent 
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	
	var margin_cont := MarginContainer.new()
	margin_cont.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin_cont)
	
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin_cont.add_child(vbox)
	
	for group in groups:
		vbox.add_child(group.visualize())
	
	return scroll
