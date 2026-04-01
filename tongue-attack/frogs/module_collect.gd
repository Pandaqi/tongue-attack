extends Node2D
class_name ModuleCollect

@export var entity : Frog
@export var area : Area2D
@export var col_shape : CollisionShape2D
@export var thickness := 16.0
@export var offset_y := 16.0

@export var module_desires : ModuleDesires
@export var module_tongue : ModuleTongue

@export var audio_collect : AudioStreamPlayer2D
@export var audio_good : AudioStreamPlayer2D
@export var audio_bad : AudioStreamPlayer2D

var want_to_collect : Array[Collectible] = []

signal collected(c:Collectible, good:bool)

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _physics_process(_dt:float) -> void:
	check_outstanding_collects()

# @NOTE: We separated this from the _on_body_entered function
# To resolve situations where ModuleTongue sticks to something AND the collector overlaps it within the same physics frame
func check_outstanding_collects() -> void:
	if want_to_collect.size() <= 0: return
	for col in want_to_collect:
		try_collect(col)
	want_to_collect = []

func update_area(p1:Vector2, p2:Vector2) -> void:
	var mid := 0.5 * (p1 + p2)
	var rot := (p2 - p1).angle()
	var size := p1.distance_to(p2)
	
	area.set_position(to_local(mid) + Vector2.UP * offset_y)
	area.set_rotation(rot)
	
	var shape := RectangleShape2D.new()
	shape.size = Vector2(size, thickness)
	col_shape.shape = shape

func can_collect(body:Collectible) -> bool:
	if not body.can_be_collected(): return false
	return true

func get_collection_result(body:Collectible) -> bool:
	return module_desires.matches(body.desire)

func _on_body_entered(body:Node) -> void:
	if not (body is Collectible): return
	var is_good := get_collection_result(body)
	
	# lots of helpers to "narrowly miss" collecting bad ones
	# @TODO: REPLACE WITH JUST A SMALLER "BAD COLLECTIBLES AREA"
	if Global.config.be_generous_with_wrong_collections and (not is_good):
		# if it's already below our area's Y position, ignore it
		if body.global_position.y > area.global_position.y: return
		
		# we use a smaller area
		var tongue_tip_pos := module_tongue.get_tip_position()
		var dist_y := absf(body.global_position.y - tongue_tip_pos.y)
		if dist_y < 0.5 * thickness: return
		
		# if we're near the end of the the tongue, we might as well have missed it
		var dist_to_tip : float = body.global_position.distance_to()
		if dist_to_tip <= 128.0 and module_tongue.state == ModuleTongue.State.RETRACTING: return
	
	want_to_collect.append(body)

func try_collect(body:Collectible) -> void:
	if not can_collect(body): return
	var is_good := get_collection_result(body)
	if (not is_good) and (not Global.config.pick_up_wrong_collectibles): 
		entity.change_score(Global.config.collectibles_wrong_score_penalty, body)
		return
	
	AudioManager.play_audio_nice(audio_collect)
	if is_good: AudioManager.play_audio_nice(audio_good)
	else: AudioManager.play_audio_nice(audio_bad)
	
	collected.emit(body, is_good)
	body.kill(true)
