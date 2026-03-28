extends Control
class_name TouchAreas

var areas : Array[InputTouchArea] = []
var anchors : Array[Control.LayoutPreset] = [Control.PRESET_TOP_LEFT, Control.PRESET_BOTTOM_RIGHT, Control.PRESET_BOTTOM_LEFT, Control.PRESET_TOP_RIGHT]

@export var area_container : Control

func add_area(a:InputTouchArea) -> void:
	areas.append(a)
	area_container.add_child(a)
	var anchor_to_use := anchors[a.get_touch_area_index()]
	
	## I don't know why the fuck I had to set the offset to MINSIZE, but it's the only way that it actually listens to the preset before it
	a.set_anchors_and_offsets_preset(anchor_to_use, LayoutPresetMode.PRESET_MODE_MINSIZE)
