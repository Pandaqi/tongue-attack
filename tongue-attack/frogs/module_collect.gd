extends Node2D
class_name ModuleCollect

@export var area : Area2D
@export var col_shape : CollisionShape2D
@export var thickness := 16.0
@export var offset_y := 16.0

@export var module_desires : ModuleDesires

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
	want_to_collect.append(body)

func try_collect(body:Collectible) -> void:
	if not can_collect(body): return
	var is_good := get_collection_result(body)
	if (not is_good) and (not Global.config.pick_up_wrong_collectibles): return
	collected.emit(body, is_good)
	body.kill(true)
