extends CanvasLayer
class_name UI

@export var progression : Progression
@export var lives_label : Label
@export var score_label : Label

func _ready() -> void:
	progression.lives_changed.connect(_on_lives_changed)
	progression.score_changed.connect(_on_score_changed)

func _on_lives_changed(l:int) -> void:
	lives_label.set_text("Lives: " + str(l))

func _on_score_changed(s:int) -> void:
	score_label.set_text("Score: " + str(s))
