extends Node2D
class_name BackgroundLily

@export var anim_player : AnimationPlayer
@export var sprite : Sprite2D

func _ready() -> void:
	anim_player.speed_scale = randf_range(0.7, 1.35)
	sprite.set_frame(randi() % 4)
	if randf() <= 0.5: anim_player.play("float")
	else: anim_player.play_backwards("float")
