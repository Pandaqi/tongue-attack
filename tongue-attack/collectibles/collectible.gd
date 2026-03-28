extends CharacterBody2D
class_name Collectible

@export var gravity_speed := 30.0
@export var sprite_stone : Sprite2D
@export var visualizer : DesireVisualizer
@export var col_shape : CollisionShape2D
@export var squasher_stretcher : SquasherStretcher
@export var timer_move_pattern : Timer

var stone_base_scale := 512.0

var frozen := false
var desire : Desire
var collected := false
var collectible := true
var out_of_play := false # not a type that any player wants right now

var moving := true

signal killed(c:Collectible)

func _ready() -> void:
	gravity_speed = randf_range(Global.config.gravity_bounds.x, Global.config.gravity_bounds.y)
	sprite_stone.hide()
	timer_move_pattern.wait_time = Global.config.flying_collectibles_pattern_timer_duration
	timer_move_pattern.timeout.connect(_on_timer_move_pattern_timeout)

func _on_timer_move_pattern_timeout() -> void:
	moving = not moving

func set_type(d:Desire) -> void:
	desire = d
	visualizer.flip_horizontally(randf() <= 0.5)
	visualizer.set_data(desire)
	
	col_shape.shape = CircleShape2D.new()
	col_shape.shape.radius = 0.5 * visualizer.size
	
	timer_move_pattern.stop()
	var has_move_pattern := (desire.type is DesireTypeIcons) and DesireTypeIcons.types_with_animation.has(desire.value)
	if has_move_pattern: timer_move_pattern.start()

func clear_type() -> void:
	desire = null
	visualizer.queue_free()
	visualizer = null

func make_stone() -> void:
	make_uncollectible()
	clear_type()
	
	var size_stone := Global.config.size_stone 
	sprite_stone.show()
	sprite_stone.set_scale(size_stone / stone_base_scale * Vector2.ONE)
	gravity_speed = randf_range(Global.config.gravity_bounds_stone.x, Global.config.gravity_bounds_stone.y)
	
	col_shape.shape = RectangleShape2D.new()
	col_shape.shape.size = Vector2(0.25*size_stone, size_stone)
	squasher_stretcher.set_paused(true)

func make_out_of_play() -> void:
	out_of_play = true

func make_uncollectible() -> void:
	collectible = false

func can_be_collected() -> bool:
	return collectible and (not frozen)

func _physics_process(_dt: float) -> void:
	fall()
	check_if_off_screen()

func fall() -> void:
	velocity = Vector2.DOWN * gravity_speed
	if frozen or (not moving): velocity = Vector2.ZERO
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

func kill(was_collected := false) -> void:
	collected = was_collected
	visualizer.on_killed()
	killed.emit(self)
	queue_free()
