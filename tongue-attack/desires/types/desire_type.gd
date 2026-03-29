extends Resource
class_name DesireType

## unique identifier for this type
## used for checking if enabled in settings and if two desires are equal type
@export var key : String

## get all possible values within this overarching type
static func get_all_types():
	pass

## show the correct visuals for being/wanting the thing
func visualize(_d:Desire, _dv:DesireVisualizer):
	pass

## play audio saying the thing
func narrate(_d:Desire) -> AudioStream:
	return null

## for custom ways in which types are the same (or not) that aren't handled by default comparison
## this is checked both ways (matches(d1,d2) or matches(d2,d1)) as we have no guarantees about which is which
func matches_custom(_d1:Desire, _d2:Desire) -> bool:
	return false
