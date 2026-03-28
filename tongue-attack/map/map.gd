extends Node2D
class_name Map

@export var leaf_positions_container : Node2D
@export var leaf_scene : PackedScene
var leaves : Array[Leaf] = []
var leaves_available : Array[Leaf] = []
var leaf_positions : Array[Vector2] = []

func _ready() -> void:
	place_leaves()

func place_leaves() -> void:
	leaf_positions = []
	for child in leaf_positions_container.get_children():
		leaf_positions.append(child.global_position)
	
	for pos in leaf_positions:
		var l : Leaf = leaf_scene.instantiate()
		l.set_position(pos)
		var is_on_right := pos.x > 0.5*get_viewport_rect().size.x
		l.set_direction(is_on_right)
		add_child(l)
		leaves.append(l)
	
	leaves_available = leaves.duplicate(false)
	leaves_available.shuffle()
	
func get_next_leaf() -> Leaf:
	return leaves_available.pop_back()

func give_back_leaf(leaf:Leaf) -> void:
	leaves_available.append(leaf)
