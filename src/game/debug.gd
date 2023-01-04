extends Node

var play_as_npcs := true
var allow_pick_pins := true

func get_picked_pins() -> Dictionary:
	var debug_pick_group := get_tree().get_nodes_in_group('debug_pin_pick')
	if debug_pick_group.empty():
		return {}
	
	var debug_pick := debug_pick_group[0] as Node
	return debug_pick.get_picks() as Dictionary

func _ready() -> void:
	var pick_menus := preload('res://src/game/debug_pin_pick.tscn').instance()
	assert(pick_menus is CanvasLayer)
	add_child(pick_menus)
	if not allow_pick_pins:
		pick_menus.get_child(0).queue_free()

