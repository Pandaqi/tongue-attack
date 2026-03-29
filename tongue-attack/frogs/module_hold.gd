extends Node2D
class_name ModuleHold

@export var progress_unstuck_container : Node2D
@export var progress_unstuck_bar : TextureProgressBar
@export var module_tongue : ModuleTongue

var can_start_new_hold := true

signal finished()

func _ready() -> void:
	z_index = 512
	_on_input_released(0.0)

func _on_input_released(_time_held:float) -> void:
	can_start_new_hold = true
	progress_unstuck_container.hide()

func _on_input_held(time_held:float) -> void:
	if not can_start_new_hold: return
	
	var time_needed := Global.config.time_needed_to_get_unstuck
	var factor := time_held / time_needed
	
	progress_unstuck_container.show()
	progress_unstuck_bar.value = factor
	progress_unstuck_container.set_position(Vector2.ZERO)
	
	if module_tongue.state == ModuleTongue.State.STUCK:
		progress_unstuck_container.set_position(module_tongue.get_tip_area_position())
	
	if factor < 1.0: return
	finish()

func finish() -> void:
	can_start_new_hold = false
	progress_unstuck_container.hide()
	finished.emit()
