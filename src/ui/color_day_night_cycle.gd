class_name ColorDayNightCycle
extends Node

export(Color) var day: Color
export(Color) var evening: Color
export(Color) var night: Color

func _ready():
	if 'color' in get_parent():
		var day_time := TimeCycle.get_day_time()
		match day_time:
			TimeCycle.DayTime.Day: get_parent().color = day
			TimeCycle.DayTime.Evening: get_parent().color = evening
			TimeCycle.DayTime.Night: get_parent().color = night
