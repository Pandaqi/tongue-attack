extends Node2D
class_name ModuleCollect

@export var area : Area2D
@export var col_shape : CollisionShape2D
@export var thickness := 16.0

@export var module_desires : ModuleDesires

signal collected(c:Collectible, good:bool)

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func update_area(p1:Vector2, p2:Vector2) -> void:
	var mid := 0.5 * (p1 + p2)
	var rot := (p2 - p1).angle()
	var size := p1.distance_to(p2)
	
	area.set_position(to_local(mid))
	area.set_rotation(rot)
	
	var shape := RectangleShape2D.new()
	shape.size = Vector2(size, thickness)
	col_shape.shape = shape

func can_collect(body:Collectible) -> bool:
	if not body.can_be_collected(): return false
	return true

func _on_body_entered(body:Node) -> void:
	if not (body is Collectible): return
	if not can_collect(body): return
	var is_good := module_desires.matches(body.desire)
	collected.emit(body, is_good)
	body.kill()
