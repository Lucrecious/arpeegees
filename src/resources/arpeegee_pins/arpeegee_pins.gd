extends Node

# Order is dynamic for random picks, don't assume consistent order
var _pins := []

var _player_pins := []
var _npc_pins := []

func _ready() -> void:
	_pins = _get_and_load_pickable_pins('res://src/resources/arpeegee_pins/')
	_player_pins = _get_of_type(_pins, ArpeegeePin.Type.Player)
	_npc_pins = _get_of_type(_pins, ArpeegeePin.Type.NPC)

# always picks at least 1 player and 1 npc
func pick_random(amount: int) -> Dictionary:
	if amount < 2:
		assert(false, 'minimum two must be picked')
		return {}
	
	if amount > _pins.size():
		assert(false, 'not enough pins')
		return {}
	
	if _player_pins.empty():
		assert(false, 'not enough player pins')
		return {}
	
	if _npc_pins.empty():
		assert(false, 'not enough npc pins')
		return {}
	
	var player := _player_pins[randi() % _player_pins.size()] as ArpeegeePin
	var npc := _npc_pins[randi() % _npc_pins.size()] as ArpeegeePin
	
	# we're going to pick first (n - 2) so shuffling them...
	_pins.shuffle()
	_pins.erase(player)
	_pins.erase(npc)
	_pins.push_back(player)
	_pins.push_back(npc)
	
	var results := {
		players = [player],
		npcs = [npc],
		other = []
	}
	
	for i in amount - 2:
		var pin := _pins[i] as ArpeegeePin
		if pin.type == ArpeegeePin.Type.Player:
			results.players.push_back(pin)
		elif pin.type == ArpeegeePin.Type.NPC:
			results.npcs.push_back(pin)
		else:
			results.other.push_back(pin)
	
	return results

func _get_of_type(pins: Array, type: int) -> Array:
	var of_type := []
	
	for pin in pins:
		if (pin as ArpeegeePin).type != type:
			continue
		of_type.push_back(pin)
	
	return of_type

func _get_and_load_pickable_pins(directory_path: String) -> Array:
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
		
		if arpeegee_pin.pickable:
			pins.push_back(arpeegee_pin)
		
		file_name = directory.get_next()
	 
	directory.list_dir_end() # just in case
	
	return pins
