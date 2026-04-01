extends Resource
class_name GameOverDataSystem

@export var header : String = "GO_HEADER"
@export_multiline var message : String = "GO_MESSAGE"

var we_won := false
var winning_player : PlayerSystem

# common properties in these situations
var score := 0
var lives := 0
var time := 0

func get_header() -> String:
	return header

func get_message() -> String:
	return message
