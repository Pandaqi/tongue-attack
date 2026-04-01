extends GameOverDataSystem
class_name GameOverData

var lives_left := 0
var time_spent := 0

func get_header() -> String:
	if we_won: return "GAME_OVER_HEADER_GOOD"
	return "GAME_OVER_HEADER_BAD"

func get_message() -> String:
	var txt := tr("GAME_OVER_MESSAGE_BAD").format({
		"score": score,
		"time": time_spent
	})
	
	if we_won: 
		txt = tr("GAME_OVER_MESSAGE_GOOD").format({
		"lives": lives_left,
		"time": time_spent
	})
	
	return txt
