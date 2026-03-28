extends Control
class_name ButtonVisualizerContainer

@export var vis : ButtonVisualizer

const BASE_SCALE := Vector2(512, 512)

func refresh_size(s:Vector2) -> void:
	custom_minimum_size = s
	
	# sprite to show
	vis.set_position(0.5 * s)
	
	var new_scale := s / BASE_SCALE
	var scale_uniform := minf(new_scale.x, new_scale.y)
	vis.set_scale(Vector2.ONE * scale_uniform)
