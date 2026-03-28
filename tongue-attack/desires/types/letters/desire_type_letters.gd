extends DesireType
class_name DesireTypeLetters

enum Type
{
	A, B, C, D, E, F, G, H, I, 
	J, K, L, M, N, O, P, Q, R,
	S, T, U, V, W, X, Y, Z
}

static var word_library : Array[String] = [
	"apple", "bee", "cactus", "free", "frog", "fly", "hello", "heat", "pond", "leaf",
	"red", "blue", "yellow", "green", "black", "white", "pink", "big", "small", "round", "square",
	"dog", "cat", "bird", "fish", "elephant", "tiger", "horse", "duck", "rabbit", "bear",
	"mum", "dad", "brother", "sister", "baby", "friend", "teacher", "boy", "girl", "person",
	"apple", "banana", "bread", "milk", "water", "juice", "egg", "cheese", "cake", "yummy",
	"eat", "drink", "sleep", "wake up", "wash", "brush", "go", "come", "play", "jump", "run", "stop",
	"ball", "book", "car", "box", "chair", "table", "door", "light", "toy", "bag",
	"sun", "rain", "cloud", "snow", "wind", "hot", "cold", "tree", "flower", "grass",
	"happy", "sad", "angry", "tired", "excited", "scared", "proud", "love",
	"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
	"fast", "slow", "clean", "dirty", "new", "old", "soft", "loud"
]

# @TODO: Actually add the individual letter audio

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

static func convert_type_to_letter(tp:Type) -> String:
	return get_all_type_strings()[tp]

static func convert_type_to_audio(tp:Type) -> String:
	return "res://tongue-attack/desires/types/letters/letter-" + convert_type_to_letter(tp).to_lower() + ".ogg"

static func get_random_word_containing_letter(letter:String) -> String:
	word_library.shuffle()
	for word in word_library:
		if word.contains(letter.to_lower()): return word
	return ""

func visualize(d:Desire, dv:DesireVisualizer) -> void:
	var letter_needed := convert_type_to_letter(d.value)
	dv.sprite.hide()
	
	# if this is not final, we just display the LETTER we want
	if not dv.is_final():
		d.value_visualized = letter_needed
		dv.set_text(letter_needed)
		return
	
	# otherwise we display a full word that contains it
	var rand_word := get_random_word_containing_letter(letter_needed)
	d.value_visualized = rand_word
	dv.set_text("[wave]" + rand_word + "[/wave]")

func narrate(d:Desire) -> AudioStream:
	return load(convert_type_to_audio(d.value))

## we also match if one of them contains the string of the other
func matches_custom(d1:Desire, d2:Desire) -> bool:
	if not (d1.type is DesireTypeLetters): return false
	if not (d2.type is DesireTypeLetters): return false
	return d1.value_visualized.contains(d2.value_visualized) or d2.value_visualized.contains(d1.value_visualized)
