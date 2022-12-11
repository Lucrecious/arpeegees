extends Node

enum DayTime {
	Day,
	Evening,
	Night,
}

func _ready() -> void:
	var time := Time.get_datetime_dict_from_system()
	Logger.info('current hour: %d' % time.hour)
	_print_day_time(get_day_time())

func _print_day_time(day_time: int) -> void:
	match day_time:
		DayTime.Day: Logger.info('current day time: Day')
		DayTime.Evening: Logger.info('current day time: Evening')
		DayTime.Night: Logger.info('current day time: Night')

func get_day_time() -> int:
	var time := Time.get_datetime_dict_from_system()
	
	if time.hour >= 6 and time.hour < 17:
		return DayTime.Day
	
	if time.hour >= 17 and time.hour < 22:
		return DayTime.Evening
	
	return DayTime.Night
