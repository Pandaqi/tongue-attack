extends Node2D
class_name ScreenAnchorTool 

enum Anchor
{
	CENTER,
	TOP,
	RIGHT,
	BOTTOM,
	LEFT,
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	CORNERS
}

var anchor := Anchor.CENTER
var element_size := Vector2(128, 128)
var element_scale := 1.0
var margin := Vector2.ZERO
var elements : Array = []

const CONTROL_PRESETS : Dictionary[Anchor, Control.LayoutPreset] = {
	Anchor.CENTER: Control.PRESET_CENTER,
	Anchor.LEFT: Control.PRESET_CENTER_LEFT,
	Anchor.RIGHT: Control.PRESET_CENTER_RIGHT,
	Anchor.TOP: Control.PRESET_CENTER_TOP,
	Anchor.BOTTOM: Control.PRESET_CENTER_BOTTOM,
	Anchor.TOP_LEFT: Control.PRESET_TOP_LEFT,
	Anchor.TOP_RIGHT: Control.PRESET_TOP_RIGHT,
	Anchor.BOTTOM_LEFT: Control.PRESET_BOTTOM_LEFT,
	Anchor.BOTTOM_RIGHT: Control.PRESET_BOTTOM_RIGHT,
	Anchor.CORNERS: Control.PRESET_TOP_LEFT
}

static func get_control_preset(a:Anchor) -> Control.LayoutPreset:
	return CONTROL_PRESETS[a]

static func set_control_node(c:Control, a:Anchor) -> void:
	c.set_anchors_preset(get_control_preset(a), false)
	c.call_deferred("reset_size")

static func set_control_node_with_offset(c:Control, a:Anchor) -> void:
	#c.set_anchors_preset(get_control_preset(a), false)
	c.set_anchors_and_offsets_preset(get_control_preset(a), Control.PRESET_MODE_MINSIZE)
	# c.call_deferred("reset_size")

static func needs_vertical_box(a:Anchor) -> bool:
	return [Anchor.LEFT, Anchor.RIGHT].has(a)
