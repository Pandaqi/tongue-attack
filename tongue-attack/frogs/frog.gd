extends PlayerSystem
class_name Frog

@export var module_collect : ModuleCollect
@export var module_tongue : ModuleTongue
@export var module_tongue_visuals : ModuleTongueVisuals
@export var module_desires : ModuleDesires
@export var module_visuals : ModuleVisuals

var leaf : Leaf
var offset_on_leaf := Vector2(64.0, 32.0)

signal scored(val:float)
signal lives_lost(val:int)
signal request_leaf_reposition(f:Frog)

func _ready() -> void:
	module_input.quick_pressed.connect(module_tongue._on_input_quick_pressed)
	module_input.held.connect(module_tongue._on_input_held)
	module_input.released.connect(module_tongue._on_input_released)
	module_input.visualizers_refreshed.connect(_on_visualizers_refreshed)
	
	module_tongue.tongue_changed.connect(module_collect.update_area)
	module_tongue.state_changed.connect(module_visuals.update_state)
	module_tongue.fully_extended.connect(_on_tongue_fully_extended)
	module_collect.collected.connect(module_desires._on_collected)
	module_collect.collected.connect(_on_collected)

func _on_collected(_c:Collectible, good:bool) -> void:
	leaf.on_collect()
	
	if good: 
		scored.emit(Global.config.score_per_correct_item)
		return
	
	lives_lost.emit(-1)

func _on_tongue_fully_extended() -> void:
	if not Global.config.switch_leaves_if_fully_extended: return
	request_leaf_reposition.emit(self)

func place_on_leaf(lf:Leaf) -> void:
	leaf = lf
	
	var facing_dir := Vector2.LEFT if leaf.on_right else Vector2.RIGHT
	set_facing_direction(facing_dir)
	set_position(leaf.global_position + Vector2(facing_dir.x, 1) * offset_on_leaf)
	module_tongue.on_leaf_reposition()
	_on_visualizers_refreshed()

func _on_visualizers_refreshed() -> void:
	var vis := module_input.get_button_visualizer()
	if not vis: return
	vis.set_position(global_position + Vector2.UP * 128.0)

func set_facing_direction(dir:Vector2) -> void:
	module_tongue.set_facing_direction(dir)
	module_visuals.set_facing_direction(dir)

func kill() -> void:
	killed.emit(self)
	queue_free()
