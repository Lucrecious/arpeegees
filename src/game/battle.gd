class_name BattleScreen
extends Control

signal pins_dropped()

const LayoutTwoOne := preload('res://src/game/battle/layout_two_one.tscn')
const LayoutOneOne := preload('res://src/game/battle/layout_one_one.tscn')

export(bool) var auto_start := false
export(Array, Resource) var auto_start_player_pins := []
export(Array, Resource) var auto_start_npc_pins := []
export(bool) var auto_start_item := false
export(PinItemPowerUp.Type) var auto_start_item_type := PinItemPowerUp.Type.HP

var _layout: BattleLayout = null

onready var _battle_viewport := $ViewportContainer/Viewport as Viewport
onready var _battle_layer := $'%BattleLayer' as YSort
onready var _turn_manager := $'%TurnManager' as TurnManager
onready var _narrator := $'%Narrator' as NarratorUI
onready var _original_narrator_position := _narrator.rect_position

func _ready() -> void:
	_narrator.rect_position += Vector2.DOWN * (_narrator.rect_size.y - 500.0)
	
	if auto_start:
		var item_powerup: PinItemPowerUp
		if auto_start_item:
			item_powerup = load('res://src/resources/items/item.tscn').instance()
			item_powerup.as_type(auto_start_item_type)
		
		var pins := {
			players = auto_start_player_pins,
			npcs = auto_start_npc_pins,
			item_powerup = item_powerup,
		}
		start(pins)

var _started := false
func start(pins: Dictionary) -> void:
	if _started:
		assert(false)
		return
	
	_started = true
	
	_configure_viewport(_battle_viewport)
	var layout_scene: PackedScene
	if _is_two_one_layout(pins.npcs.size(), pins.players.size()):
		layout_scene = LayoutTwoOne
	elif _is_one_one_layout(pins.npcs.size(), pins.players.size()):
		layout_scene = LayoutOneOne
	else:
		assert(false, 'scenario not defined yet')
		return
	
	_layout = _create_battle_layout(layout_scene, pins)
	_drop_character_pins(pins)

func _configure_viewport(viewport: Viewport) -> void:
	var max_superscaling := 2560
	
	var scale :=  max_superscaling / viewport.size.x
	
	viewport.size *= scale
	
	viewport.canvas_transform = get_tree().root.canvas_transform
	
	viewport.get_texture().flags = Texture.FLAG_FILTER
	viewport.canvas_transform = viewport.canvas_transform.scaled(Vector2.ONE * scale)

func _is_two_one_layout(amount1: int, amount2: int) -> bool:
	return (amount1 == 1 and amount2 == 2) or (amount1 == 2 and amount2 == 1)

func _is_one_one_layout(amount1: int, amount2: int) -> bool:
	return amount1 == 1 and amount2 == 1

func _create_battle_layout(layout_scene: PackedScene, pins: Dictionary) -> BattleLayout:
	var mirrored := false
	if pins.npcs.size() < pins.players.size():
		mirrored = true
	elif pins.npcs.size() == pins.players.size():
		mirrored = ((randi() % 2) == 0)
	
	var layout := layout_scene.instance() as BattleLayout
	assert(layout, 'must be battle layout')
	_battle_layer.add_child(layout)
	if mirrored:
		layout.mirror()
	
	return layout

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
	
	var max_wait_sec := .5
	var bounce_sec := 1.5
	
	var item_powerup := pins.item_powerup as PinItemPowerUp
	var item_position := _layout.get_item_position()
	
	connect('pins_dropped', self, '_on_pins_dropped', [max_wait_sec + bounce_sec])
	_load_and_drop_pins(players + npcs, right_positions + left_positions, item_powerup, item_position,
			max_wait_sec, bounce_sec)

func _on_pins_dropped(wait_sec: float) -> void:
	_wait_for_drop_to_finish(wait_sec)

func _wait_for_drop_to_finish(wait_sec: float) -> void:
	Music.play_theme()
	
	var tween_to_intro_narration := get_tree().create_tween()
	tween_to_intro_narration.tween_interval(wait_sec)
	tween_to_intro_narration.tween_callback(self, '_do_intro_narration')

func _do_intro_narration() -> void:
	var speaking_tween := create_tween()
	
	speaking_tween.tween_property(_narrator, 'rect_position:y', _original_narrator_position.y, 1.5)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	speaking_tween.tween_interval(0.5)
	speaking_tween.tween_callback(_narrator, 'speak_tr', ['NARRATOR_BATTLE_INTRODUCTION_GENERIC', false])
	TweenExtension.pause_until_signal(speaking_tween.parallel(), _narrator, 'speaking_ended')
	speaking_tween.tween_callback(self, '_balance_battle')

func _balance_battle() -> void:
	_turn_manager.connect('battle_ended', self, '_on_battle_ended')
	
	var nodes := NodE.get_children(_battle_layer, ArpeegeePinNode)
	_turn_manager.initialize_turns(nodes)
	
	var item := NodE.get_child(_battle_layer, PinItemPowerUp, false) as PinItemPowerUp
	if item:
		_turn_manager.use_item(item)
	
	var type_disadvanged := _turn_manager.balance_battle()
	
	var disadvantage_dialog := ''
	
	match type_disadvanged:
		ArpeegeePin.Type.Player:
			disadvantage_dialog = 'NARRATOR_HERO_FILLED_WITH_GUTS'
		ArpeegeePin.Type.NPC:
			disadvantage_dialog = 'NARRATOR_MONSTER_FILL_WITH_EVIL'
	
	if disadvantage_dialog.empty():
		_start_battle(nodes)
	else:
		var tween := create_tween()
		TweenExtension.pause_until_signal(tween, _narrator, 'speaking_ended')
		tween.tween_callback(self, '_start_battle', [nodes])
		_narrator.speak_tr(disadvantage_dialog, true)

func _on_battle_ended(end_condition: int) -> void:
	if end_condition == TurnManager.EndCondition.NPCsDead:
		_narrator.speak_tr('NARRATOR_BATTLE_FINISHED_HEROES_WIN_GENERIC', true)
		_change_to_win_sprites(_turn_manager.get_players())
	elif end_condition == TurnManager.EndCondition.PlayersDead:
		_narrator.speak_tr('NARRATOR_BATTLE_FINISHED_MONSTERS_WIN_GENERIC', true)
		_change_to_win_sprites(_turn_manager.get_npcs())
	elif end_condition == TurnManager.EndCondition.EveryoneDead:
		_narrator.speak_tr('NARRATOR_BATTLE_FINISHED_TIED_GENERIC', true)
	else:
		assert(false)

func _change_to_win_sprites(pins: Array) -> void:
	for p in pins:
		var sprite_switcher := NodE.get_child(p, SpriteSwitcher) as SpriteSwitcher
		sprite_switcher.change('win')

func _start_battle(nodes: Array) -> void:
	for n in nodes:
		_narrator.watch(n)
	_turn_manager.step_turn()

func _load_and_drop_pins(pins: Array, positions: PoolVector2Array, item: Node2D, item_position,
		wait_sec: float, bounce_sec: float) -> void:
	var background_resource_loader := BackgroundResourceLoader.new()
	get_tree().root.call_deferred('add_child', background_resource_loader)
	
	var tween := create_tween()
	TweenExtension.pause_until_signal(tween, background_resource_loader, 'finished')
	tween.tween_callback(background_resource_loader, 'queue_free')
	tween.tween_callback(self, '_drop_pins', [positions, pins, item, item_position,
			background_resource_loader, wait_sec, bounce_sec])
	
	var scene_paths := PoolStringArray([])
	
	for i in positions.size():
		var pin := pins[i] as ArpeegeePin
		scene_paths.push_back(pin.scene_path)
	
	background_resource_loader.load(scene_paths)

func _drop_pins(positions: PoolVector2Array, pins: Array, item: PinItemPowerUp, item_position: Vector2,
		loader: BackgroundResourceLoader, wait_sec: float, bounce_sec: float) -> void:
	
	var pin_resources := loader.result as Array
	for i in positions.size():
		var pin := pins[i] as ArpeegeePin
		
		var pin_node_scene := pin_resources[i] as PackedScene
		var pin_node := pin_node_scene.instance() as ArpeegeePinNode
		
		_battle_layer.add_child(pin_node)
		var position := positions[i]
		
		pin_node.global_position = position + Vector2.UP * 1000.0
		
		pin_node.emit_stars()
		
		var drop_tween := get_tree().create_tween()
		drop_tween.tween_interval(rand_range(0.0, wait_sec))
		drop_tween.tween_property(pin_node, 'global_position:y', position.y, bounce_sec)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_BOUNCE)
		drop_tween.tween_callback(pin_node, 'stop_star_emission')
	
	if item:
		_battle_layer.add_child(item)
		var position := item_position
		
		item.global_position = position + Vector2.UP * 1000.0
		
		var drop_tween := get_tree().create_tween()
		drop_tween.tween_interval(rand_range(0.0, wait_sec))
		drop_tween.tween_property(item, 'global_position:y', position.y, bounce_sec)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_BOUNCE)
	
	emit_signal('pins_dropped')

func _input(input: InputEvent) -> void:
	var mouse_button := input as InputEventMouseButton
	if not mouse_button:
		return
	
	if mouse_button.pressed and mouse_button.button_index == BUTTON_LEFT:
		_narrator.skip()
