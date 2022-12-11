class_name TextureDayNightCycle
extends Node

export(Texture) var day: Texture
export(Texture) var evening: Texture
export(Texture) var night: Texture

func _ready():
	if 'texture' in get_parent():
		var day_time := TimeCycle.get_day_time()
		match day_time:
			TimeCycle.DayTime.Day: get_parent().texture = day
			TimeCycle.DayTime.Evening: get_parent().texture = evening
			TimeCycle.DayTime.Night: get_parent().texture = night
