extends Node2D
class_name ModuleVisuals

@export var sprite : Sprite2D
@export var sprite_hat : Sprite2D
@export var hat_container : Node2D
@export var squasher_stretcher : SquasherStretcher

func _on_input_activated(mp:ModuleInput) -> void:
	sprite_hat.set_frame(mp.get_player_index())

func set_facing_direction(dir:Vector2) -> void:
	sprite.flip_h = dir.x < 0
	hat_container.rotation = -absf(hat_container.rotation) * signf(dir.x)

func update_state(s:ModuleTongue.State) -> void:
	var frm := 0 if s == ModuleTongue.State.IDLE else 1
	sprite.set_frame(frm)
	
	squasher_stretcher.set_paused(s != ModuleTongue.State.IDLE)
