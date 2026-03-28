extends Node
class_name PlayerSpawner 

@export var player_scene : PackedScene
@export var player_data : PlayerData = preload("res://pq-obg/players/player_data.tres")

@export var container : Node
@export var clear_input_on_reload := false

func _enter_tree() -> void:
	player_data.reset(Global.config_system.player_colors)

func _ready() -> void:
	Global.input.button_added.connect(_on_button_added)
	Global.input.button_removed.connect(_on_button_removed)
	Global.input.buttons_changed.connect(_on_buttons_changed)
	
	# init calls
	if clear_input_on_reload: Global.input.clear()
	var btns_already_in_play = Global.input.buttons_used.duplicate()
	for btn in btns_already_in_play:
		place_player(btn)
	
	# @NOTE: delay because if we call now other objects' _ready() might not have triggered yet
	await get_tree().process_frame
	Global.input.buttons_changed.emit()

func _on_button_added(btn:InputButton) -> void:
	place_player(btn)

func _on_button_removed(btn:InputButton) -> void:
	remove_player(btn)

func place_player(btn:InputButton) -> void:
	var p : PlayerSystem = player_scene.instantiate()
	container.add_child(p)
	player_data.add_player(p)
	p.module_input.activate(btn)
	
	if p.has_node("ModuleStatus"):
		p.get_node("ModuleStatus").revive()
	
	p.revived.emit()

func remove_player(btn:InputButton) -> void:
	var connected_player := get_player_with_button(btn)
	if not connected_player: return
	
	connected_player.module_input.deactivate()
	player_data.remove_player(connected_player)
	
	if connected_player.has_node("ModuleStatus"):
		connected_player.get_node("ModuleStatus").die()
		return
	
	connected_player.killed.emit()
	connected_player.queue_free()

func get_player_with_button(btn:InputButton) -> PlayerSystem:
	for p in player_data.players:
		if p.module_input.button == btn:
			return p
	return null

func _on_buttons_changed() -> void:
	for p in player_data.players:
		var btn := p.module_input.button
		if Global.input.is_button_possible(btn): continue
		var new_btn := Global.input.get_next_button_any()
		if not new_btn: continue
		p.module_input.activate(btn)
