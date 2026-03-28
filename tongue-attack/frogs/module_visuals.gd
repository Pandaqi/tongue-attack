extends Node2D
class_name ModuleVisuals

@export var sprite : Sprite2D
@export var squasher_stretcher : SquasherStretcher

func set_facing_direction(dir:Vector2) -> void:
	sprite.flip_h = dir.x < 0

func update_state(s:ModuleTongue.State) -> void:
	var frm := 0 if s == ModuleTongue.State.IDLE else 1
	sprite.set_frame(frm)
	
	squasher_stretcher.set_paused(s != ModuleTongue.State.IDLE)
