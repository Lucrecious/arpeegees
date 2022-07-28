class_name BattleScreen
extends Control

const LayoutTwoOne := preload('res://src/game/battle/layout_two_one.tscn')
const ArpeegeePinNode := preload('res://src/game/arpeegee_pin.tscn')

export(int) var pin_count := 3

var _layout: BattleLayout = null

onready var _viewport := $BattleViewport/Viewport as Viewport

func _ready() -> void:
	var pins := ArpeegeePins.pick_random(pin_count)
	if _is_two_one_layout(pins.npcs.size(), pins.players.size()):
		_layout = _create_battle_layout(LayoutTwoOne, pins)
		_drop_character_pins(pins)
	else:
		assert(false, 'scenario not defined yet')

func _drop_character_pins(pins: Dictionary) -> void:
	var left_positions := _layout.get_left_positions()
	var right_positions := _layout.get_right_positions()
	var npcs := pins.npcs as Array
	var players := pins.players as Array
	if left_positions.size() != npcs.size():
		assert(false)
		return
	
	if right_positions.size() != players.size():
		assert(false)
		return
	
	_drop_pins(players, right_positions)
	_drop_pins(npcs, left_positions)

func _drop_pins(pins: Array, positions: PoolVector2Array) -> void:
	for i in positions.size():
		var pin_node := ArpeegeePinNode.instance() as ArpeegeePinNode
		var npc := pins[i] as ArpeegeePin
		pin_node.arpeegee_pin = npc
		
		_viewport.add_child(pin_node)
		var position := positions[i]
		
		pin_node.global_position = position + Vector2.UP * 1000.0
		
		var drop_tween := get_tree().create_tween()
		drop_tween.tween_interval(rand_range(0.0, 0.7))
		drop_tween.tween_property(pin_node, 'global_position:y', position.y, 1.0)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_BOUNCE)

func _create_battle_layout(layout_scene: PackedScene, pins: Dictionary) -> BattleLayout:
	var mirrored := (pins.npcs.size() == 1) as bool
	var layout := _create_layout(layout_scene)
	_viewport.add_child(layout)
	if mirrored:
		layout.mirror()
	
	return layout

func _create_layout(layout_scene: PackedScene) -> BattleLayout:
	var instance := layout_scene.instance() as BattleLayout
	assert(instance, 'must be battle layout')
	
	return instance

func _is_two_one_layout(amount1: int, amount2: int) -> bool:
	return (amount1 == 1 and amount2 == 2) or (amount1 == 2 and amount2 == 1)
