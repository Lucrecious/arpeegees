extends Node

func _ready() -> void:
	Logger.output_format = '[{TIME}] [{LVL}]: {MSG}'
	Logger.time_format = 'hh:mm:ss'
	Logger.set_max_memory_size(100)
	var module := Logger.get_module(Logger.default_module_name) as Logger.Module
	if OS.is_debug_build():
		module.set_common_output_strategy(Logger.STRATEGY_PRINT)
	else:
		module.set_common_output_strategy(Logger.STRATEGY_MEMORY)
