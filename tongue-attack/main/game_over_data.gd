extends GameOverDataSystem
class_name GameOverData

var we_won := false
var score := 0
var lives_left := 0
var time_spent := 0

func get_header() -> String:
	if we_won: return "Congratulations!"
	return "Game Over!"

func get_message() -> String:
	var txt := "You're out of lives. You scored {score} froggy coins and survived {time} seconds.".format({
		"score": score,
		"time": time_spent
	})
	
	if we_won: 
		txt = "You reached the maximum score with {lives} lives remaining! All frogs are happy. It only took you {time} seconds.".format({
		"lives": lives_left,
		"time": time_spent
	})
	
	return txt
