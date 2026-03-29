extends DesireType
class_name DesireTypeShapes

@export var value_debug : Type
enum Type
{
	TRIANGLE,
	SQUARE,
	RECTANGLE,
	PENTAGON,
	HEXAGON,
	OCTAGON,
	CIRCLE,
	ELLIPSE,
}

static var type_to_audio : Dictionary[Type, String] = {
	Type.TRIANGLE: "triangle",
	Type.SQUARE: "square",
	Type.RECTANGLE: "rectangle",
	Type.PENTAGON: "pentagon",
	Type.HEXAGON: "hexagon",
	Type.OCTAGON: "octagon",
	Type.CIRCLE: "circle",
	Type.ELLIPSE: "ellipse",
}

var shape_scene := load("res://tongue-attack/desires/types/shapes/shape.tscn")

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

static func convert_type_to_audio(tp:Type) -> String:
	return "res://tongue-attack/desires/types/shapes/" + type_to_audio[tp] + ".ogg"

func visualize(d:Desire, dv:DesireVisualizer) -> void:
	var shape : Shape = shape_scene.instantiate()
	dv.add_child(shape)
	var make_shape_wonky := dv.is_final()
	shape.set_size(0.33 * dv.size)
	shape.set_type(d.value, make_shape_wonky)

func narrate(d:Desire) -> AudioStream:
	return load(convert_type_to_audio(d.value))
