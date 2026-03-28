extends Node2D
class_name ModuleTongueVisuals

@export var module_tongue : ModuleTongue

@export var line : Line2D
@export var thickness := 32.0

@export var sprite_start : Node2D
@export var sprite_end : Node2D

func _ready() -> void:
	module_tongue.state_changed.connect(update_state)
	module_tongue.tongue_changed.connect(update)
	
	line.width = thickness
	line.points = []

func update(p1:Vector2, p2:Vector2) -> void:
	var p1_local := to_local(p1)
	var p2_local := to_local(p2)
	
	line.points = [p1_local, p2_local]
	
	# this makes the texture UVs correct; the line is obviously identical in reverse
	if p2_local.x < p1_local.x:
		line.points = [p2_local, p1_local]
	
	if sprite_start: 
		sprite_start.show()
		sprite_start.set_position(p1_local)
	
	if sprite_end: 
		sprite_end.show()
		sprite_end.set_position(p2_local)

func update_direction(s:Node2D) -> void:
	if not s: return
	s.scale.x = 1 if module_tongue.direction.x > 0 else -1

func update_state(state:ModuleTongue.State) -> void:
	update_direction(sprite_start)
	update_direction(sprite_end)
	
	if state == ModuleTongue.State.IDLE:
		if sprite_start: sprite_start.hide()
		if sprite_end: sprite_end.hide()
