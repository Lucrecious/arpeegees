extends Node

# Order is dynamic for random picks, don't assume consistent order
var _pins := []

var _player_pins := []
var _npc_pins := []

func _ready() -> void:
	_pins = _get_and_load_pins('res://src/resources/arpeegee_pins/')
	_player_pins = _get_of_type(_pins, ArpeegeePin.Type.Player)
	_npc_pins = _get_of_type(_pins, ArpeegeePin.Type.NPC)

# always picks at least 1 player and 1 npc
func pick_random(amount: int) -> Array:
	if amount < 2:
		assert(false, 'minimum two must be picked')
		return []
	
	if amount > _pins.size():
		assert(false, 'not enough pins')
		return []
	
	if _player_pins.empty():
		assert(false, 'not enough player pins')
		return []
	
	if _npc_pins.empty():
		assert(false, 'not enough npc pins')
		return []
	
	var player := _player_pins[randi() % _player_pins.size()] as ArpeegeePin
	var npc := _npc_pins[randi() % _npc_pins.size()] as ArpeegeePin
	
	# put picked player and npc pins at the back
	var player_index := _pins.find(player)
	var npc_index := _pins.find(npc)
	var tmp_pin1 = _pins[-1]
	var tmp_pin2 = _pins[-2]
	_pins[player_index] = tmp_pin1
	_pins[npc_index] = tmp_pin2
	_pins[-1] = player
	_pins[-2] = npc
	
	var pins := [player, npc]
	
	for i in amount - 2:
		# choose from anything except last two (since they hold player and npc)
		var random_index := randi() % (_pins.size() - 2)
		pins.push_back(_pins[random_index])
	
	return pins

func _get_of_type(pins: Array, type: int) -> Array:
	var of_type := []
	
	for pin in _pins:
		if (pin as ArpeegeePin).type != type:
			continue
		of_type.push_back(pin)
	
	return of_type

func _get_and_load_pins(directory_path: String) -> Array:
	var pins := []
	
	var directory := Directory.new()
	var result := directory.open(directory_path)
	
	if result != OK:
		assert(false)
		return []
	
	var skip_navigational := true
	var skip_hidden := true
	directory.list_dir_begin(skip_navigational, skip_hidden)
	
	var file_name := directory.get_next()
	while not file_name.empty():
		if not file_name.ends_with('.tres'):
			file_name = directory.get_next()
			continue
		
		var arpeegee_pin := load(directory_path.plus_file(file_name)) as ArpeegeePin
		if not arpeegee_pin:
			assert(false, 'all resources in this folder must be arpeegee pins')
			file_name = directory.get_next()
			continue
		
		pins.push_back(arpeegee_pin)
		
		file_name = directory.get_next()
	 
	directory.list_dir_end() # just in case
	
	return pins
