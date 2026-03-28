extends Node2D
class_name Shape

@export var outline : Line2D
@export var fill : Polygon2D

var outline_thickness := 2.0
var base_size := Vector2.ONE

var type : DesireTypeShapes.Type
var wonky := false
var points : PackedVector2Array

static var type_to_num_vertices : Dictionary[DesireTypeShapes.Type, int] = {
	DesireTypeShapes.Type.TRIANGLE: 3,
	DesireTypeShapes.Type.SQUARE: 4,
	DesireTypeShapes.Type.PENTAGON: 5,
	DesireTypeShapes.Type.HEXAGON: 6,
	DesireTypeShapes.Type.OCTAGON: 8,
	DesireTypeShapes.Type.CIRCLE: 32,
}

static func create_polygon(num_vertices := 4, size := Vector2.ONE, make_wonky := false) -> PackedVector2Array:
	var arr := []
	
	var starting_angle := 0.0
	if num_vertices == 4: starting_angle = 0.25*PI
	for i in range(num_vertices):
		var angle := starting_angle + i * 2 * PI / num_vertices
		var pos := Vector2.from_angle(angle) * size
		if make_wonky:
			var rand_offset := Vector2.from_angle(randf() * 2 * PI) * randf_range(0.0, 0.15) * size
			pos += rand_offset
		
		arr.append(pos)
	
	return arr

func generate_points() -> PackedVector2Array:
	var new_points : PackedVector2Array
	if type == DesireTypeShapes.Type.RECTANGLE:
		new_points = create_polygon(type_to_num_vertices[DesireTypeShapes.Type.SQUARE], Vector2(1.25,0.65)*base_size, false)
	elif type == DesireTypeShapes.Type.ELLIPSE:
		new_points = create_polygon(type_to_num_vertices[DesireTypeShapes.Type.CIRCLE], Vector2(1.25, 0.65)*base_size, false)
	else:
		new_points = create_polygon(type_to_num_vertices[type], base_size, wonky)
	return new_points

func set_size(s:float) -> void:
	base_size = Vector2.ONE * s

func set_type(tp:DesireTypeShapes.Type, make_wonky := false) -> void:
	type = tp
	wonky = make_wonky
	points = generate_points()
	
	fill.polygon = points
	outline.points = points
	outline.width = outline_thickness
