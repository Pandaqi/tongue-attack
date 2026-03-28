extends CanvasLayer
class_name ButtonInstructions 

@export var button_instruction_scene : PackedScene = preload("res://pq-obg/ui/button_instructions/button_instruction.tscn")

var instructions : Array[ButtonInstruction] = []
var instructions_by_type : Dictionary[InputButton.InputType,ButtonInstruction] = {}
@export var root_container : Control
@export var margin_container : Control
@export var instruction_container : BoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	create_instructions()
	create_touch_area_layer()
	Global.input.buttons_changed.connect(_on_buttons_changed)
	_on_buttons_changed()

	Global.pause_mode_change.connect(_on_pause_changed)
	_on_pause_changed()
	
	# if we call it immediately, then its parent is still busy setting up children and thus the calculated values might be wrong
	call_deferred("update_anchor")

func update_anchor() -> void:
	var anchor := Global.config_system.button_instructions_anchor
	instruction_container.vertical = ScreenAnchorTool.needs_vertical_box(anchor)
	ScreenAnchorTool.set_control_node_with_offset(root_container, anchor)

func create_touch_area_layer() -> void:
	var node := CanvasLayer.new()
	node.layer = 32
	node.name = "TouchAreas"
	get_parent().call_deferred("add_child", node)

func _on_pause_changed() -> void:
	instruction_container.modulate.a = 1.0 if get_tree().paused else 0.5

func create_instructions() -> void:
	var all_types := Global.input.get_all_input_types()
	for type in all_types:
		var instruc : ButtonInstruction = button_instruction_scene.instantiate()
		instruction_container.add_child(instruc)
		instructions.append(instruc)
		instructions_by_type[type] = instruc

func _on_buttons_changed() -> void:
	# set everything to the right (next) button
	for type in instructions_by_type:
		if type == InputButton.InputType.NONE: continue
		var btn := Global.input.get_next_button(type)
		
		var node := instructions_by_type[type]
		if not btn: 
			node.hide()
			continue
		node.show()
		node.activate(btn, ButtonInstruction.Type.LOGIN)
	
	# go one ahead to show the logout instruction too
	instructions[InputButton.InputType.NONE].activate(null, ButtonInstruction.Type.LOGOUT)
	
	# tell anchor tool to show all elements that should be visible
	# anchor_tool.show_elements(instructions.slice(0, counter))

#const instruction_size := Vector2(1024, 512)
#@export var margin_off_edge := Vector2(100, 100)
#var anchor_tool : ScreenAnchorTool

#func prepare_anchor_tool() -> void:
	#anchor_tool = ScreenAnchorTool.new(
		#Global.config_system.button_instructions_anchor,
		#instruction_size, Global.config_system.button_instructions_sprite_scale, 
		#margin_off_edge
	#)
	#add_child(anchor_tool)
