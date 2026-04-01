extends PlayerSystem
class_name Frog

@export var module_collect : ModuleCollect
@export var module_tongue : ModuleTongue
@export var module_tongue_visuals : ModuleTongueVisuals
@export var module_desires : ModuleDesires
@export var module_visuals : ModuleVisuals
@export var module_hold : ModuleHold

@export var heart_texture : AtlasTexture
@export var heart_bad_texture : AtlasTexture
@export var score_texture : AtlasTexture
@export var score_bad_texture : Texture2D

var leaf : Leaf
var offset_on_leaf := Vector2(64.0, 32.0)

signal scored(val:float)
signal lives_changed(val:int)
signal request_leaf_reposition(f:Frog, dy:int)

func _ready() -> void:
	module_input.activated.connect(module_visuals._on_input_activated)
	module_input.quick_pressed.connect(module_tongue._on_input_quick_pressed)
	
	module_input.held.connect(module_hold._on_input_held)
	module_input.released.connect(module_hold._on_input_released)
	
	module_hold.finished.connect(module_tongue._on_input_hold_finished)
	module_hold.finished.connect(_on_input_hold_finished)
	
	module_input.visualizers_refreshed.connect(_on_visualizers_refreshed)
	
	module_tongue.tongue_changed.connect(module_collect.update_area)
	module_tongue.state_changed.connect(module_visuals.update_state)
	module_tongue.fully_extended.connect(_on_tongue_fully_extended)
	module_collect.collected.connect(module_desires._on_collected)
	module_collect.collected.connect(_on_collected)

func _on_collected(c:Collectible, good:bool) -> void:
	leaf.on_collect()
	
	# reward good collections!
	if good: 
		change_score(Global.config.score_per_correct_item, c)
		return
	
	# it wasn't a good collection ... but we're not penalized for those!
	if not Global.config.penalty_wrong_collectibles:
		return
	
	# it was bad, and our config says it's bad, so deduct a life!
	change_lives(-1, c)

func change_score(ds:int, c:Collectible) -> void:
	if ds < 0:
		TweenManager.give_feedback(self, get_feedback_position(), tr("FB_OHNO"))
		TweenManager.give_feedback(self, to_local(c.global_position), "", score_bad_texture)
	if ds > 0:
		TweenManager.give_feedback(self, get_feedback_position(), tr("FB_YUMMY"))
		TweenManager.give_feedback(self, to_local(c.global_position), "", score_texture)
	scored.emit(ds)

func change_lives(dl:int, c:Collectible) -> void:
	if dl < 0:
		TweenManager.give_feedback(self, get_feedback_position(), tr("FB_OHNO"))
		TweenManager.give_feedback(self, to_local(c.global_position), "", heart_bad_texture)
	if dl > 0:
		TweenManager.give_feedback(self, to_local(c.global_position), "", heart_texture)
	
	lives_changed.emit(dl)

func get_feedback_position() -> Vector2:
	return Vector2.ZERO

func _on_tongue_fully_extended() -> void:
	if not Global.config.switch_leaves_if_fully_extended: return
	if not Global.config.allow_frog_hopping: return
	request_leaf_reposition.emit(self, 0)

func _on_input_hold_finished() -> void:
	if not Global.config.switch_leaves_vertically_on_hold: return
	if module_tongue.state != ModuleTongue.State.IDLE: return
	if not Global.config.allow_frog_hopping: return
	request_leaf_reposition.emit(self, 1)

func place_on_leaf(lf:Leaf) -> void:
	var old_leaf := leaf
	leaf = lf
	
	var facing_dir := Vector2.LEFT if leaf.on_right else Vector2.RIGHT
	set_facing_direction(facing_dir)
	set_position(leaf.global_position + Vector2(facing_dir.x, 1) * offset_on_leaf)
	module_tongue.on_leaf_reposition()
	_on_visualizers_refreshed()
	
	if old_leaf:
		TweenManager.give_feedback(self, get_feedback_position(), tr("FB_MOVED"))

func _on_visualizers_refreshed() -> void:
	var vis := module_input.get_button_visualizer()
	if not vis: return
	vis.set_position(global_position + Vector2.UP * 164.0)

func set_facing_direction(dir:Vector2) -> void:
	module_tongue.set_facing_direction(dir)
	module_visuals.set_facing_direction(dir)

func kill() -> void:
	killed.emit(self)
	queue_free()
