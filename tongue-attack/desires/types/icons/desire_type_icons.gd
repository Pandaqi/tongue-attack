extends DesireType
class_name DesireTypeIcons

@export var value_debug : Type

enum Type
{
	WORM,
	SNAIL,
	LADYBUG,
	BUTTERFLY,
	BEE,
	FIREFLY,
	LOTUS,
}

static var type_to_frame : Dictionary[Type, int] = {
	Type.WORM: 1,
	Type.SNAIL: 2,
	Type.LADYBUG: 3,
	Type.BUTTERFLY: 4,
	Type.BEE: 6,
	Type.FIREFLY: 8,
	Type.LOTUS: 10,
}

static var types_with_animation := [Type.BUTTERFLY, Type.BEE, Type.FIREFLY]

static var type_to_audio : Dictionary[Type, String] = {
	Type.WORM: "worm",
	Type.SNAIL: "snail",
	Type.LADYBUG: "ladybug",
	Type.BUTTERFLY: "butterfly",
	Type.BEE: "bee",
	Type.FIREFLY: "firefly",
	Type.LOTUS: "lily",
}

static func get_random_type() -> Type:
	return get_all_types().pick_random()

static func get_all_types() -> Array[Type]:
	var arr : Array[Type] = []
	arr.assign(Type.values())
	return arr

static func get_all_type_strings() -> Array[String]:
	var arr : Array[String] = []
	arr.assign(Type.keys())
	return arr

static func convert_type_to_frame(tp:Type) -> int:
	return type_to_frame[tp]

static func convert_type_to_audio(tp:Type) -> String:
	return "res://tongue-attack/desires/types/icons/" + type_to_audio[tp] + ".ogg"

func visualize(d:Desire, dv:DesireVisualizer) -> void:
	dv.sprite.show()
	
	var frm := type_to_frame[d.value]
	dv.sprite.set_frame(frm)
	
	if dv.is_final() and types_with_animation.has(d.value):
		var tw := dv.sprite.get_tree().create_tween()
		var rand_dur := randf_range(0.065, 0.12)
		tw.tween_property(dv.sprite, "frame", frm, rand_dur)
		tw.tween_property(dv.sprite, "frame", frm+1, rand_dur)
		tw.set_loops(0)
		dv.tween_active = tw

func narrate(d:Desire) -> AudioStream:
	return load(convert_type_to_audio(d.value))

func matches_custom(d1:Desire, d2:Desire) -> bool:
	if not (d1.type is DesireTypeIcons): return false
	if not (d2.type is DesireTypeNumbers): return false
	if d2.value_visualized == null: return false
	return d1.value == d2.value_visualized
