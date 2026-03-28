extends Resource
class_name GameOverDataSystem

@export var header : String = "GO_HEADER"
@export_multiline var message : String = "GO_MESSAGE"

func get_header() -> String:
	return header

func get_message() -> String:
	return message
