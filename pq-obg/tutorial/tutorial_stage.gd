extends Resource
class_name TutorialStage

enum Type
{
	OBJECTIVE, # how do you score/win, what are you trying to do
	GAME_OVER, # when does the game end
	BUTTON_PRESS, # what pressing your button does
	BUTTON_HOLD, # what holding your button does
	GAMEPLAY # custom gameplay explanations
}

@export var type := Type.GAMEPLAY

@export var texture : Texture
@export var heading := "" # a custom heading that overrules the usual
@export var audio : AudioStream
@export var settings_required : Array[String] = [] # the tutorial only shows if these settings are true
@export_multiline var content := "" # text to display (instead of image)

func is_valid() -> bool:
	for setting in settings_required:
		if not (setting in Global.config): return false
		if not Global.config[setting]: return false
	return true
