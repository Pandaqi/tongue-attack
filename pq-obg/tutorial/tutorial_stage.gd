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
@export_multiline var content := "" # text to display (instead of image)
