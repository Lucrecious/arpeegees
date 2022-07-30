extends Node

const DEFAULT_ICON_PATH := 'res://assets/ui/icons/sword_attack.png'
const ICON_DIRECTORY_PATH := 'res://assets/ui/icons/'

var _name_to_icon_path := {}

func _ready() -> void:
	var directory := Directory.new()
	directory.open(ICON_DIRECTORY_PATH)
	
	var error := directory.list_dir_begin(true, true)
	if error != OK:
		assert(false)
		return
	
	var file := directory.get_next()
	while not file.empty():
		if not file.ends_with('.png'):
			file = directory.get_next()
			continue
		
		_name_to_icon_path[file.left(file.find_last('.'))] = ICON_DIRECTORY_PATH.plus_file(file)
		
		file = directory.get_next()
	
	directory.list_dir_end()

func get(name: String) -> Texture:
	var path := _name_to_icon_path.get(name, DEFAULT_ICON_PATH) as String
	var texture := load(path) as Texture
	return texture
