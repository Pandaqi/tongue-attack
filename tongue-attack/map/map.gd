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
	var children := leaf_positions_container.get_children()
	children.reverse() # why the fuck does it gather children in reverse order?
	for child in children:
		leaf_positions.append(child.global_position)
	
	for pos in leaf_positions:
		var l : Leaf = leaf_scene.instantiate()
		l.set_position(pos)
		var is_on_right := pos.x > 0.5*get_viewport_rect().size.x
		l.set_direction(is_on_right)
		add_child(l)
		leaves.append(l)
	
	leaves_available = leaves.duplicate(false)
	
	if Global.config.randomize_leaf_positions:
		leaves_available.shuffle()

func get_leaf_in_direction(leaf:Leaf, dy := +1) -> Leaf:
	# if no Y difference, then find the same one on the opposite side
	if dy == 0: return get_leaf_opposite(leaf)
	
	# otherwise, find the best leaf in the Y-direction chosen
	var y_pos := leaf.global_position.y
	
	var leaves_same_side := leaves.filter(func(l:Leaf): return l.on_right == leaf.on_right and l != leaf)
	
	# this is shorthand for ...
	# if dy > 0 and other_leaf.global_position.y < y_pos: continue
	# if dy < 0 and other_leaf.global_position.y > y_pos: continue
	var leaves_in_direction := leaves_same_side.filter(func(l:Leaf): return dy*l.global_position.y > dy*y_pos)
	var no_leaves_there := leaves_in_direction.size() <= 0
	if no_leaves_there: leaves_in_direction = leaves_same_side
	
	var best_dist := 0.0 if no_leaves_there else INF
	var best_leaf : Leaf
	for other_leaf in leaves_in_direction:
		var dist := absf(other_leaf.global_position.y - y_pos)
		if no_leaves_there and dist <= best_dist: continue # if no leaves, we actually want the one FURTHEST AWAY (wrapping to other side)
		if (not no_leaves_there) and dist >= best_dist: continue
		best_dist = dist
		best_leaf = other_leaf
	
	return best_leaf

func get_leaf_opposite(leaf:Leaf) -> Leaf:
	var on_right_target := not leaf.on_right
	var y_pos_target := leaf.global_position.y
	var best_dist := INF
	var best_leaf : Leaf
	for other_leaf in leaves:
		if other_leaf.on_right != on_right_target: continue
		var dist := absf(other_leaf.global_position.y - y_pos_target)
		if dist >= best_dist: continue
		best_dist = dist
		best_leaf = other_leaf
	return best_leaf

func get_next_leaf() -> Leaf:
	return leaves_available.pop_back()

func take_leaf(leaf:Leaf) -> void:
	leaves_available.erase(leaf)

func give_back_leaf(leaf:Leaf) -> void:
	leaves_available.append(leaf)

func is_leaf_available(leaf:Leaf) -> bool:
	return leaves_available.has(leaf)
