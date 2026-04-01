extends CanvasLayer
class_name UI

@export var progression : Progression

@export var lives_container : HBoxContainer
@export var lives_icon : TextureRect
@export var lives_label : Label
var lives_icons : Array[TextureRect] = []

@export var score_container : HBoxContainer
@export var score_icon : TextureRect
@export var score_label : Label
var score_icons : Array[TextureRect] = []

@export var debug := false

func _ready() -> void:
	lives_icons = [lives_icon]
	for i in range(Global.config.max_lives - 1):
		var icon := lives_icon.duplicate()
		lives_icons.append(icon)
		lives_container.add_child(icon)
	
	score_icons = [score_icon]
	for i in range(Global.config.max_score_icons - 1):
		var icon := score_icon.duplicate()
		score_icons.append(icon)
		score_container.add_child(icon)	
	
	progression.lives_changed.connect(_on_lives_changed)
	progression.score_changed.connect(_on_score_changed)
	
	if not (debug and OS.is_debug_build()):
		lives_label.hide()
		score_label.hide()

func _on_lives_changed(l:int) -> void:
	lives_label.set_text("Lives: " + str(l))
	TweenManager.play_flash_tween(lives_container)
	for i in range(lives_icons.size()):
		lives_icons[i].set_visible(i < l)

func _on_score_changed(s:int) -> void:
	score_label.set_text("Score: " + str(s))
	TweenManager.play_flash_tween(score_container)
	var score_discrete := roundi( (s / float(progression.target_score)) * score_icons.size() )
	for i in range(score_icons.size()):
		score_icons[i].set_visible(i < score_discrete)
