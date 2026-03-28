extends CanvasLayer

@export var color_rect : ColorRect
@export var bg_image_container : Node2D
@export var bg_image : Sprite2D

func _ready() -> void:
	color_rect.color = Global.config_system.bg_color
	if Global.config_system.bg_image:
		bg_image.texture = Global.config_system.bg_image
	
	get_tree().get_root().size_changed.connect(refresh)
	refresh()

func refresh() -> void:
	var vp := get_viewport().get_visible_rect().size
	bg_image_container.set_position(0.5*vp)
	if bg_image.texture:
		var base_scale := bg_image.texture.get_size()
		var target_scale := vp / base_scale
		var uniform_scale := maxf(target_scale.x, target_scale.y)
		bg_image.set_scale(Vector2.ONE * uniform_scale)
