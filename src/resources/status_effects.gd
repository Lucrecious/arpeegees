extends Node

const EffectsDirectoryPath := 'res://src/resources/status_effects/'

var _effect_names_to_scene_path := {}

func _ready() -> void:
	_effect_names_to_scene_path = _get_effect_names_to_scene_path()

func instance(effects_name: String) -> StatusEffect:
	var effect_path := _effect_names_to_scene_path.get(effects_name, '') as String
	if effect_path.empty():
		assert(false)
		return null
	
	var scene := load(effect_path) as PackedScene
	var effect := scene.instance() as StatusEffect
	
	if not effect:
		assert(false)
		return null
	
	return effect

func _get_effect_names_to_scene_path() -> Dictionary:
	var directory := Directory.new()
	var result := directory.open(EffectsDirectoryPath)
	if result != OK:
		return {}
	
	var effects_to_scene_path := {}
	
	directory.list_dir_begin(true, true)
	while true:
		var file_name := directory.get_next()
		
		if file_name.empty():
			break
		
		if not file_name.ends_with('.tscn'):
			continue
		
		var key_name = file_name.left(file_name.find_last('.'))
		effects_to_scene_path[key_name] = EffectsDirectoryPath.plus_file(file_name)
	
	directory.list_dir_end()
	
	return effects_to_scene_path
