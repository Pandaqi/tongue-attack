extends Control
class_name Tutorial 

var stages : Array[TutorialStage] = []

@export var container : Control
@export var box_container : BoxContainer
@export var timer : Timer
var sprite_scene : PackedScene = preload("res://pq-obg/tutorial/tutorial_sprite.tscn")
var sprites : Array[TutorialSprite] = []

var enabled := false
var active := false
var current_stage := -1
var num_times_shown := 0 # this means WITHIN THE SAME GAME (so when players pause/resume several times)

func _ready() -> void:
	enabled = Global.config_system.tutorial_enabled
	if not enabled: hide()
	timer.timeout.connect(_on_timer_timeout)
	prepare_sprites()
	call_deferred("update_anchor")

func is_active() -> bool:
	return enabled and active

func prepare_sprites() -> void:
	if not enabled: return
	
	# collect the right stages
	stages = Global.config_system.tutorials.duplicate(false)
	var debug_stages : Array[TutorialStage] = Global.config_system.tutorials_debug.duplicate(false)
	if debug_stages.size() > 0: stages = debug_stages
	
	for i in range(stages.size() -1, -1, -1):
		if stages[i].is_valid(): continue
		stages.remove_at(i)
	
	# create objects for them
	for i in range(count()):
		var t : TutorialSprite = sprite_scene.instantiate()
		box_container.add_child(t)
		sprites.append(t)
		t.refresh_size(Global.config_system.tutorial_scale)
		t.set_stage(stages[i])

func set_active(val:bool) -> void:
	if not enabled: return
	if Global.config_system.tutorial_only_once and num_times_shown > 0: 
		disappear()
		return
	
	active = val
	if val:
		appear()
	else:
		disappear()

func appear() -> void:
	show()
	
	num_times_shown += 1
	
	# make them pop into view one by one
	goto_next_stage()

func goto_next_stage() -> void:
	if not is_active(): return
	
	current_stage = clampi(current_stage + 1, -1, count())
	if current_stage == -1 or current_stage == count():
		return
	
	sprites[current_stage].appear()
	restart_timer()

func _on_timer_timeout() -> void:
	goto_next_stage()

func restart_timer() -> void:
	timer.stop()
	timer.wait_time = Global.config_system.tutorial_delay
	timer.start()

func disappear() -> void:
	hide()
	active = false
	
	for sprite in sprites:
		sprite.disappear()

func count() -> int:
	return stages.size()

func update_anchor() -> void:
	var anchor := Global.config_system.tutorial_anchor
	box_container.vertical = ScreenAnchorTool.needs_vertical_box(anchor)
	ScreenAnchorTool.set_control_node_with_offset(container, anchor)
