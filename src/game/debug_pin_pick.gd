extends Control

onready var _heroes_menu := $'%HeroesMenu' as MenuButton
onready var _npcs_menu := $'%NPCsMenu' as MenuButton
onready var _pins_menu := $'%PinMenu' as MenuButton

var _hero_picked := -1
var _npc_picked := -1
var _pin_picked := -1

func get_picks() -> Dictionary:
	var randoms := ArpeegeePins.pick_random(3)
	var picks := { players = [], npcs = [], item_powerup = null }
	
	if _hero_picked != -1:
		var hero := _heroes_menu.get_popup().get_item_metadata(_hero_picked) as ArpeegeePin
		picks.players.push_back(hero)
	
	if _npc_picked != -1:
		var npc := _npcs_menu.get_popup().get_item_metadata(_npc_picked) as ArpeegeePin
		picks.npcs.push_back(npc)
	
	if _pin_picked != -1:
		var pin := _pins_menu.get_popup().get_item_metadata(_pin_picked) as ArpeegeePin
		if pin.type == ArpeegeePin.Type.NPC:
			picks.npcs.push_back(pin)
		elif pin.type == ArpeegeePin.Type.Player:
			picks.players.push_back(pin)
		else:
			assert(false)
	
	if picks.players.empty():
		picks.players = randoms.players
	
	if picks.npcs.empty():
		picks.npcs = randoms.npcs
	
	return picks

func _ready():
	var heroes_popup := _heroes_menu.get_popup()
	var heroes := ArpeegeePins.get_player_pin_resources()
	for i in heroes.size():
		var h := heroes[i] as ArpeegeePin
		heroes_popup.add_item(_file_path_to_readable(h))
		heroes_popup.set_item_metadata(i, h)
	
	var npcs_popup := _npcs_menu.get_popup()
	var npcs := ArpeegeePins.get_npc_pin_resources()
	for i in npcs.size():
		var n := npcs[i] as ArpeegeePin
		npcs_popup.add_item(_file_path_to_readable(n))
		npcs_popup.set_item_metadata(i, n)
	
	var pins_popup := _pins_menu.get_popup()
	var pins := ArpeegeePins.get_all_pin_resources()
	for i in pins.size():
		var p := pins[i] as ArpeegeePin
		pins_popup.add_item(_file_path_to_readable(p))
		pins_popup.set_item_metadata(i, p)
	
	heroes_popup.connect('index_pressed', self, '_on_heroes_index_pressed')
	npcs_popup.connect('index_pressed', self, '_on_npcs_index_pressed')
	pins_popup.connect('index_pressed', self, '_on_pins_index_pressed')

func _on_heroes_index_pressed(index: int) -> void:
	_hero_picked = index
	_heroes_menu.text = _heroes_menu.get_popup().get_item_text(index)

func _on_npcs_index_pressed(index: int) -> void:
	_npc_picked = index
	_npcs_menu.text = _npcs_menu.get_popup().get_item_text(index)

func _on_pins_index_pressed(index: int) -> void:
	_pin_picked = index
	var pin := _pins_menu.get_popup().get_item_metadata(index) as ArpeegeePin
	_pins_menu.text = _pins_menu.get_popup().get_item_text(index)

func _file_path_to_readable(pin: ArpeegeePin) -> String:
	var path := pin.resource_path
	var filename := path.get_file()
	var name := filename.left(filename.find_last('.'))
	name = name.replace('_', ' ')
	
	var suffix := '(Player)' if pin.type == ArpeegeePin.Type.Player else '(NPC)'
	
	return '%s %s' % [name, suffix]
