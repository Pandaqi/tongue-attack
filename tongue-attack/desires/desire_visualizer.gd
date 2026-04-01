extends Node2D
class_name DesireVisualizer

@export var background : Sprite2D
@export var sprite : Sprite2D
@export var label_container : Node2D
@export var label : RichTextLabel
@export var audio_narrate : AudioStreamPlayer2D
@export var anim_player : AnimationPlayer

@export var final := false # whether it's the final actual desire, or just the thing representing we want it
@export var size := 32.0
var base_sprite_size := 256.0

var desire : Desire
var tween_active : Tween

func flip_horizontally(fh := false) -> void:
	background.flip_h = fh
	sprite.flip_h = fh

func set_size(s:float) -> void:
	size = s
	
	var new_scale := Vector2.ONE * size / base_sprite_size
	sprite.set_scale(0.66*new_scale)
	label_container.set_scale(new_scale)
	background.set_scale(new_scale)

func set_data(d:Desire) -> void:
	desire = d
	
	background.set_visible(not final)
	sprite.hide()
	label.hide()
	
	set_size(size) # a refresh call to make sure we're at the right size BEFORE visualizing
	d.visualize(self)

func set_text(txt:String) -> void:
	label.show()
	label.set_text(txt)

func play_anim(anim_name:String) -> void:
	anim_player.play(anim_name)

func narrate() -> void:
	audio_narrate.stream = desire.narrate()
	audio_narrate.play()

func is_final() -> bool:
	return final

func on_killed() -> void:
	if tween_active: 
		tween_active.kill()
		tween_active = null

func pop_up() -> void:
	if tween_active:
		TweenManager.force_completion(tween_active)
		tween_active = null
	
	tween_active = TweenManager.play_popup_tween(self)
