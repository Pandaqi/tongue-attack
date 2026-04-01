extends Node2D
class_name ModuleDesires

@export var visualizer_scene : PackedScene
@export var element_size := 32.0

var desires : Array[Desire] = []
var visualizers : Array[DesireVisualizer] = []

# @TODO: Could be some cleaner functions about getting INDEX and converting and stuff
func get_matching_desire_visualizer(d:Desire) -> DesireVisualizer:
	for i in range(desires.size()):
		if desires[i].matches(d): return visualizers[i]
	return null

func matches(d:Desire) -> bool:
	if d == null: return false
	for desire in desires:
		if desire.matches(d): return true
	return false

func matches_any(d:Array[Desire]) -> bool:
	for dd in d:
		if matches(dd): return true
	return false

func set_all(arr:Array[Desire]) -> void:
	desires = arr
	refresh()

func get_all() -> Array[Desire]:
	return desires

func count() -> int:
	return desires.size()

func add_visualizer() -> void:
	var v : DesireVisualizer = visualizer_scene.instantiate()
	v.set_size(element_size)
	visualizers.append(v)
	add_child(v)

func refresh() -> void:
	# create more visualizers if needed
	while visualizers.size() < count():
		add_visualizer()
	
	# position center-aligned + give data to those visible
	var offset := -0.5 * (count() - 1) * element_size * Vector2.RIGHT
	for i in range(visualizers.size()):
		var should_show := i < count()
		var vis := visualizers[i]
		vis.set_visible(should_show)
		var pos := offset + i * element_size * Vector2.RIGHT
		vis.set_position(pos)
		if should_show:
			vis.set_data(desires[i])

func _on_collected(c:Collectible, good:bool) -> void:
	# @TODO: play some angry wiggle tween?
	if not good: return 
	
	var node_matched := get_matching_desire_visualizer(c.desire)
	if node_matched:
		node_matched.pop_up()
		if Global.config.narrate_desires_matched:
			# to prevent overlap with main sound effects for collecting
			await get_tree().create_timer(randf_range(0.2, 0.5)).timeout 
			node_matched.narrate()
