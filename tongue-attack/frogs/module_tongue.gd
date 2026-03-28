extends Node2D
class_name ModuleTongue

@export var debug := false
@export var can_stick_to_collectibles := false
@export var gets_stuck_at_max_extension := false

@export var tongue_tip : Area2D
 # @NOTE: never make the end 0 as then damping will never make it reach start/end pos
@export var speed_bounds := Vector2(2000.0, 300.0)
@export var direction := Vector2.RIGHT
@export var offset := Vector2(41.0, -66.0)

var max_distance := 0.0
var start_pos := Vector2.ZERO
var state := State.NONE
var object_stuck_to : Collectible

enum State
{
	NONE,
	IDLE,
	EXTENDING,
	STUCK,
	RETRACTING
}

signal state_changed(s:State)
signal tongue_changed(p1:Vector2, p2:Vector2)

func _ready() -> void:
	set_state(State.IDLE)
	tongue_tip.body_entered.connect(_on_body_entered)

func set_facing_direction(dir:Vector2) -> void:
	direction = dir
	var x_offset := offset.x if direction.x > 0 else -offset.x
	tongue_tip.set_position(Vector2(x_offset, offset.y))
	start_pos = tongue_tip.position

func _physics_process(dt:float) -> void:
	move(dt)

func is_moving() -> bool:
	return [State.EXTENDING, State.RETRACTING].has(state)

func get_tongue_length() -> float:
	return tongue_tip.position.distance_to(start_pos)

func get_signed_direction() -> int:
	return 1 if state == State.EXTENDING else -1

# We start fast, then slow down over time
func get_speed() -> float:
	var factor := get_tongue_length() / max_distance
	if get_signed_direction() == -1: factor = 1.0 - factor
	factor = pow(factor, 5) # the higher the factor, the more explosive it is at the start
	return lerpf(speed_bounds.x, speed_bounds.y, factor)

func change_position(pos:Vector2) -> void:
	tongue_tip.set_position(pos)
	tongue_changed.emit(to_global(start_pos), to_global(pos))

func reset_to_start() -> void:
	change_position(start_pos)

func reset_to_end() -> void:
	change_position(start_pos + direction * max_distance)

func calculate_max_distance() -> void:
	var total_map_width := Global.config.map_size.x
	var offset_from_edge := to_global(start_pos).x
	if offset_from_edge > 0.5*total_map_width: 
		offset_from_edge = total_map_width - offset_from_edge
	
	max_distance = total_map_width - 2*absf(offset_from_edge)

func move(dt:float) -> void:
	if not is_moving(): return
	
	calculate_max_distance()
	
	var dir := get_signed_direction()
	var new_pos := tongue_tip.get_position() + get_speed() * dir * direction * dt
	change_position(new_pos)

	var at_end := get_tongue_length() >= max_distance
	if at_end:
		reset_to_end()
		if gets_stuck_at_max_extension: get_stuck()
		else: set_state(State.RETRACTING)
		return
	
	# if dot prod < 0, the tongue is "behind" starting position now
	var back_at_start := (new_pos - start_pos).normalized().dot(direction) < 0
	if back_at_start:
		reset_to_start()
		set_state(State.IDLE)
		return

func _on_body_entered(body:Node) -> void:
	if state != State.EXTENDING: return
	if not (body is Collectible): return
	if not can_stick_to_collectibles: return
	get_stuck(body)

func _input(ev:InputEvent) -> void:
	if not debug: return
	if not OS.is_debug_build(): return
	
	if ev.is_action_released("ui_accept"):
		toggle()
	if ev.is_action_released("ui_cancel"):
		get_unstuck()

func get_stuck(body:Collectible = null) -> void:
	object_stuck_to = body
	if object_stuck_to: body.freeze()
	set_state(State.STUCK)

func get_unstuck() -> void:
	if state != State.STUCK: return
	if object_stuck_to:
		object_stuck_to.unfreeze()
		object_stuck_to = null
	set_state(State.RETRACTING)

func set_state(s:State) -> void:
	if state == s: return
	
	state = s
	state_changed.emit(s)

# @TODO: Special situation to get "unstuck" or flip again _while_ retracting?
func toggle() -> void:
	var new_state := state
	
	if state == State.IDLE:
		new_state = State.EXTENDING
	if state == State.EXTENDING:
		new_state = State.RETRACTING
	
	set_state(new_state)
