extends CharacterBody2D
class_name Collectible

@export var gravity_speed := 30.0
@export var visualizer : DesireVisualizer

var frozen := false
var desire : Desire

signal killed(c:Collectible)

func _ready() -> void:
	gravity_speed = randf_range(Global.config.gravity_bounds.x, Global.config.gravity_bounds.y)

func set_type(d:Desire) -> void:
	desire = d
	visualizer.flip_horizontally(randf() <= 0.5)
	visualizer.set_data(desire)

func can_be_collected() -> bool:
	return not frozen

func _physics_process(_dt: float) -> void:
	fall()
	check_if_off_screen()

func fall() -> void:
	velocity = Vector2.DOWN * gravity_speed
	if frozen: velocity = Vector2.ZERO
	move_and_slide()

func is_off_screen() -> bool:
	return get_global_transform_with_canvas().origin.y > get_viewport_rect().size.y

func check_if_off_screen() -> void:
	if not is_off_screen(): return
	kill()

func freeze() -> void:
	frozen = true

func unfreeze() -> void:
	frozen = false

func kill() -> void:
	visualizer.on_killed()
	killed.emit(self)
	queue_free()
