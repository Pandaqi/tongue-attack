extends DesireType
class_name DesireTypeColors


## for debugging a specific value of this thing
@export var value_debug : Type

enum Type
{
	RED,
	GREEN,
	BLUE,
	YELLOW,
	CYAN,
	MAGENTA,
	ORANGE,
	PURPLE,
	BROWN,
	BLACK,
	WHITE
}

static var type_to_color : Dictionary[Type, Color] = {
	Type.RED: Color.RED,
	Type.GREEN: Color.GREEN,
	Type.BLUE: Color.BLUE,
	Type.YELLOW: Color.YELLOW,
	Type.CYAN: Color.CYAN,
	Type.MAGENTA: Color.MAGENTA,
	Type.ORANGE: Color.ORANGE,
	Type.PURPLE: Color.PURPLE,
	Type.BROWN: Color.BROWN,
	Type.BLACK: Color(0.2, 0.2, 0.2),
	Type.WHITE: Color.WHITE,
}

static var type_to_audio : Dictionary[Type, String] = {
	Type.RED: "red",
	Type.GREEN: "green",
	Type.BLUE: "blue",
	Type.YELLOW: "yellow",
	Type.CYAN: "cyan",
	Type.MAGENTA: "pink",
	Type.ORANGE: "orange",
	Type.PURPLE: "purple",
	Type.BROWN: "brown",
	Type.BLACK: "black",
	Type.WHITE: "white",
}

const TINTABLE_LILY_FRAME := 0

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

static func convert_type_to_color(tp:Type) -> Color:
	if not (tp in type_to_color): return Color.TRANSPARENT
	return type_to_color[tp]

static func convert_type_to_audio(tp:Type) -> String:
	return "res://tongue-attack/desires/types/colors/" + type_to_audio[tp] + ".ogg"

func visualize(d:Desire, dv:DesireVisualizer) -> void:
	dv.sprite.show()
	if not dv.is_final(): dv.sprite.set_scale(dv.background.scale) # perfectly match background as it's the same lily
	dv.sprite.set_frame(TINTABLE_LILY_FRAME)
	dv.sprite.modulate = convert_type_to_color(d.value)

func narrate(d:Desire) -> AudioStream:
	return load(convert_type_to_audio(d.value))
