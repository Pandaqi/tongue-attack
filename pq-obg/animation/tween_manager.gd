extends Node2D
class_name TweenManager

var base_duration := 0.3

func force_completion(tw:Tween) -> void:
	tw.pause()
	tw.custom_step(100.0)

func play_popup_tween(obj:Node, dur := base_duration) -> Tween:
	var cur_scale = obj.scale
	var tw := get_tree().create_tween()
	tw.tween_property(obj, "scale", cur_scale*1.35, 0.33*dur)
	tw.tween_property(obj, "scale", cur_scale, 0.66*dur)
	return tw

func play_shrink_tween(obj:Node, dur := base_duration) -> Tween:
	var tw := get_tree().create_tween()
	var target_scale = Vector2.ZERO if (obj is Node2D) else Vector3.ZERO
	tw.tween_property(obj, "scale", target_scale, dur)
	return tw

func play_fadein_tween(obj:Node, dur := base_duration) -> Tween:
	obj.modulate.a = 0.0
	
	var tw := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(obj, "modulate:a", 1.0, dur)
	return tw 

func play_fadeout_tween(obj:Node, dur := base_duration) -> Tween:
	obj.modulate.a = 1.0
	
	var tw := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(obj, "modulate:a", 0.0, dur)
	return tw 

func play_rotate_tween(obj:Node, dur := base_duration, direction := 1) -> Tween:
	var tw := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var target_rotation = obj.rotation
	if obj is Node3D: target_rotation.z += direction * 2 * PI
	else: target_rotation += direction * 2 * PI
	tw.tween_property(obj, "rotation", target_rotation, dur)
	return tw
