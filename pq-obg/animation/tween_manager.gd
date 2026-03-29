extends Node2D
class_name TweenManager

static var base_duration := 0.3
static var feedback_scene := preload("res://pq-obg/animation/feedback/feedback.tscn")

static func force_completion(tw:Tween) -> void:
	tw.pause()
	tw.custom_step(100.0)

static func play_popup_tween(obj:Node, dur := base_duration) -> Tween:
	var cur_scale = obj.scale
	var tw := obj.get_tree().create_tween()
	tw.tween_property(obj, "scale", cur_scale*1.35, 0.33*dur)
	tw.tween_property(obj, "scale", cur_scale, 0.66*dur)
	return tw

static func play_shrink_tween(obj:Node, dur := base_duration) -> Tween:
	var tw := obj.get_tree().create_tween()
	var target_scale = Vector2.ZERO if (obj is Node2D) else Vector3.ZERO
	tw.tween_property(obj, "scale", target_scale, dur)
	return tw

static func play_fadein_tween(obj:Node, dur := base_duration) -> Tween:
	obj.modulate.a = 0.0
	
	var tw := obj.get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(obj, "modulate:a", 1.0, dur)
	return tw 

static func play_fadeout_tween(obj:Node, dur := base_duration) -> Tween:
	obj.modulate.a = 1.0
	
	var tw := obj.get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(obj, "modulate:a", 0.0, dur)
	return tw 

static func play_flash_tween(obj:Node, dur := base_duration, intensity := 1.5) -> Tween:
	var tw := obj.get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(obj, "modulate", Color.WHITE*intensity, 0.5*dur)
	tw.tween_property(obj, "modulate", Color.WHITE, 0.5*dur)
	return tw 

static func play_rotate_tween(obj:Node, dur := base_duration, direction := 1) -> Tween:
	var tw := obj.get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var target_rotation = obj.rotation
	if obj is Node3D: target_rotation.z += direction * 2 * PI
	else: target_rotation += direction * 2 * PI
	tw.tween_property(obj, "rotation", target_rotation, dur)
	return tw

static func give_feedback(container:Node2D, pos := Vector2.ZERO, txt:String = "", tex:Texture2D = null, scl := Vector2.ONE) -> FeedbackSystem:
	var fb : FeedbackSystem = feedback_scene.instantiate()
	container.add_child(fb)
	fb.set_position(pos)
	fb.set_size(scl)
	if tex: fb.set_sprite(tex)
	if txt: fb.set_text(txt)
	return fb
