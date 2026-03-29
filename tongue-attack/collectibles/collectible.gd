extends CharacterBody2D
class_name Collectible

@export var gravity_speed := 30.0
@export var sprite_stone : Sprite2D
@export var visualizer : DesireVisualizer
@export var col_shape : CollisionShape2D
@export var squasher_stretcher : SquasherStretcher
@export var timer_move_pattern : Timer

var stone_base_scale := 512.0

var moving := true # this responds to animations and movement patterns; built-in/self
var frozen := false # this is what outside forces can use to stop the collectible; e.g. tongue stuck
var frozen_to : ModuleTongue
var desire : Desire
var collected := false # has been succesfully collected
var collectible := true # CAN be collected
var out_of_play := false # not a type that any player wants right now
var removal_duration := 0.0 # how much time has been spend stuck to a tongue and being removed


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

func _physics_process(dt: float) -> void:
	fall()
	check_if_off_screen()
	remove_if_stuck(dt)

func remove_if_stuck(dt:float) -> void:
	if not frozen: return
	if not Global.config.collectibles_remove_over_time_if_stuck: return
	
	removal_duration += dt
	var removal_factor := clampf(removal_duration / Global.config.collectibles_remove_if_stuck_duration, 0.0, 1.0)
	modulate.a = lerp(1.0, Global.config.collectibles_remove_alpha_min, removal_factor)
	if removal_factor >= 1.0:
		kill(true)

func fall() -> void:
	velocity = Vector2.DOWN * gravity_speed
	if frozen or (not moving): velocity = Vector2.ZERO
	move_and_slide()

func is_off_screen() -> bool:
	return get_global_transform_with_canvas().origin.y > get_viewport_rect().size.y

func check_if_off_screen() -> void:
	if not is_off_screen(): return
	kill()

func freeze(mt:ModuleTongue) -> void:
	frozen = true
	frozen_to = mt

func unfreeze() -> void:
	frozen = false
	frozen_to = null

func kill(was_collected := false) -> void:
	collected = was_collected
	if visualizer: visualizer.on_killed()
	killed.emit(self)
	if frozen_to: frozen_to.get_unstuck()
	queue_free()
