extends Node
class_name Objective 

enum VictoryMetric
{
	RANKING, # a simple individual ranking
	TEAMS, # results are congregated per team
	SOLO_WINNER, # one person wins, everyone else loses
	SOLO_LOSER # one person loses, everyone else wins
}

enum VictoryType
{
	POINTS, # just a raw point value
	TIME, # a time value (usually race to lowest time)
	DISCRETE # a discrete value (X wins, Y objects collected, ...)
}

enum VictoryExtreme
{
	HIGHEST, # highest value is best
	LOWEST # lowest value is best
}

enum VictoryConversion
{
	NONE, # nothing special
	RANKING, # your _rank_ is added to your overall score
	POINT, # you get one point for winning
}
