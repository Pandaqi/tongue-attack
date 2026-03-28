extends DesireType
class_name DesireTypeNumbers

enum Type
{
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX
}

static var type_to_number : Dictionary[Type, int] = {
	Type.TWO: 2,
	Type.THREE: 3,
	Type.FOUR: 4,
	Type.FIVE: 5,
	Type.SIX: 6
}

# @TODO: Actually add this audio
static var type_to_audio : Dictionary[Type, String] = {
	Type.TWO: "two",
	Type.THREE: "three",
	Type.FOUR: "four",
	Type.FIVE: "five",
	Type.SIX: "six",
}

static func get_random_type() -> Type:
	return get_all_types().pick_random()

static func get_all_types() -> Array[Type]:
	var arr : Array[Type] = []
	arr.assign(Type.values())
	return arr

static func get_all_type_strings() -> Array[String]:
	var arr : Array[String] = []
	arr.assign(Type.keys())
	return arr

static func convert_type_to_audio(tp:Type) -> String:
	return "res://tongue-attack/desires/types/numbers/" + type_to_audio[tp] + ".ogg"

func visualize(d:Desire, dv:DesireVisualizer) -> void:
	var num_sprites_needed := type_to_number[d.value]
	
	# if this is not final, we just display the NUMBER of stuff we want
	if not dv.is_final():
		dv.sprite.hide()
		dv.set_text(str(num_sprites_needed))
		return
	
	# otherwise, we must actually DISPLAY all those sprites
	var all_sprites : Array[Sprite2D] = [dv.sprite]
	
	var rand_type := DesireTypeIcons.get_random_type()
	d.value_visualized = rand_type
	
	var matching_frame := DesireTypeIcons.convert_type_to_frame(rand_type)
	dv.sprite.show()
	dv.sprite.set_frame(matching_frame)
	
	# create as many sprites as needed
	while all_sprites.size() < num_sprites_needed:
		var new_sprite := dv.sprite.duplicate(false)
		dv.add_child(new_sprite)
		all_sprites.append(new_sprite)
	
	# arrange them in a circle around center point
	var base_scale := dv.sprite.scale
	for i in range(num_sprites_needed):
		var ang := i * (2*PI) / num_sprites_needed
		var scl := 0.85 * base_scale
		var pos := Vector2.from_angle(ang) * 0.25 * dv.size
		
		all_sprites[i].set_position(pos)
		all_sprites[i].set_rotation(ang)
		all_sprites[i].set_scale(scl)

func narrate(d:Desire) -> AudioStream:
	return load(convert_type_to_audio(d.value))
