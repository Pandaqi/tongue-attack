class_name Desire

@export var type : DesireType
@export var value : int
@export var value_visualized : Variant

func _init(tp:DesireType, val:int):
	type = tp
	value = val
	value_visualized = ""

func clone() -> Desire:
	return Desire.new(type, value)

func get_hash() -> String:
	return str(type) + str(value)

func matches(d:Desire) -> bool:
	if type.matches_custom(self, d): return true
	if type.matches_custom(d, self): return true
	return type == d.type and value == d.value

func visualize(dv:DesireVisualizer) -> void:
	type.visualize(self, dv)

func narrate() -> AudioStream:
	return type.narrate(self)
