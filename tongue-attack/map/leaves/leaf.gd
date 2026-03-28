extends Node2D
class_name Leaf

@export var anim_player : AnimationPlayer

var on_right := false

func _ready() -> void:
	anim_player.speed_scale = randf_range(0.9, 1.1)

func set_direction(on_r := false) -> void:
	on_right = on_r
	scale.x = -1 if on_right else 1

func on_collect() -> void:
	anim_player.play("wiggle")
	await anim_player.animation_finished
	anim_player.play("idle")
