extends Node2D
class_name ModuleCollect

@export var entity : Frog
@export var area_good : Area2D
@export var col_shape_good : CollisionShape2D

@export var area_bad : Area2D
@export var col_shape_bad : CollisionShape2D

@export var thickness_good := 32.0
@export var thickness_bad := 12.0
@export var offset_y := 16.0
@export var extra_length_good := 64.0
@export var extra_length_bad := -192.0

@export var module_desires : ModuleDesires
@export var module_tongue : ModuleTongue

@export var audio_collect : AudioStreamPlayer2D
@export var audio_good : AudioStreamPlayer2D
@export var audio_bad : AudioStreamPlayer2D

var want_to_collect : Array[Collectible] = []

signal collected(c:Collectible, good:bool)

func _ready() -> void:
	col_shape_good.shape = RectangleShape2D.new()
	col_shape_bad.shape = RectangleShape2D.new()
	
	area_good.body_entered.connect(_on_body_entered_good)
	area_bad.body_entered.connect(_on_body_entered_bad)

func _physics_process(_dt:float) -> void:
	check_outstanding_collects()

# @NOTE: We separated this from the _on_body_entered function
# To resolve situations where ModuleTongue sticks to something AND the collector overlaps it within the same physics frame
func check_outstanding_collects() -> void:
	if want_to_collect.size() <= 0: return
	for col in want_to_collect:
		try_collect(col)
	want_to_collect = []

func update_areas(p1:Vector2, p2:Vector2) -> void:
	var dir_vec := (p2 - p1)
	
	var p2_good := p2 + dir_vec.normalized() * extra_length_good
	dir_vec = (p2_good - p1)
	
	var mid := 0.5 * (p1 + p2_good)
	var rot := dir_vec.angle()
	var size := dir_vec.length()
	
	area_good.set_position(to_local(mid) + Vector2.UP * offset_y)
	area_good.set_rotation(rot)
	col_shape_good.shape.size = Vector2(size, thickness_good)

	var p2_bad := p2 + dir_vec.normalized() * extra_length_bad
	if size <= absf(extra_length_bad): p2_bad = p1
	var mid_bad := 0.5 * (p1 + p2_bad)
	var size_bad := p1.distance_to(p2_bad)
	
	area_bad.set_position(to_local(mid_bad) + Vector2.UP * offset_y)
	area_bad.set_rotation(rot)
	col_shape_bad.shape.size = Vector2(size_bad, thickness_bad)

func can_collect(body:Collectible) -> bool:
	if not body.can_be_collected(): return false
	return true

func get_collection_result(body:Collectible) -> bool:
	return module_desires.matches(body.desire)

func _on_body_entered_good(body:Node) -> void:
	if not (body is Collectible): return
	var is_good := get_collection_result(body)
	if not is_good: return
	want_to_collect.append(body)

func _on_body_entered_bad(body:Node) -> void:
	if not (body is Collectible): return
	var is_good := get_collection_result(body)
	if is_good: return
	
	if Global.config.be_generous_with_wrong_collections:
		if body.global_position.y >= (area_bad.global_position.y + 2.0*thickness_bad): return
	
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
