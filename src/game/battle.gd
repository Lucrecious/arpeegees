class_name BattleScreen
extends Control

signal pins_dropped()

const LayoutTwoOne := preload('res://src/game/battle/layout_two_one.tscn')
const LayoutOneTwo := preload('res://src/game/battle/layout_one_two.tscn')
const LayoutOneOne := preload('res://src/game/battle/layout_one_one.tscn')

export(bool) var auto_start := false
export(Array, Resource) var auto_start_player_pins := []
export(Array, Resource) var auto_start_npc_pins := []
export(bool) var auto_start_item := false
export(PinItemPowerUp.Type) var auto_start_item_type := PinItemPowerUp.Type.HP
onready var _sounds := NodE.get_child(self, SoundsComponent) as SoundsComponent

var _layout: BattleLayout = null

#onready var _battle_viewport := $'%BattleViewport' as Viewport
onready var _battle_layer := $'%BattleLayer' as Control
onready var _turn_manager := $'%TurnManager' as TurnManager
onready var _narrator := $'%Narrator' as NarratorUI
onready var _original_narrator_position := _narrator.rect_position

onready var bottom_bar := $'%BlackGradient' as Control
onready var restart_button := $'%RestartButton' as Button
onready var _restart_button_holder := restart_button.get_parent() as Control

onready var _restart_button_original_position := restart_button.rect_position
onready var _restart_button_holder_original_position := _restart_button_holder.rect_position

onready var _puddle_player := $'%PuddlePlayer' as AnimationPlayer

func _ready() -> void:
	_puddle_player.play('RESET')
	
	_narrator.rect_position += Vector2.LEFT * (_narrator.rect_size.x + 500.0)
	_restart_button_holder.rect_position += Vector2.UP * (restart_button.rect_size.y + 100.0)
	
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
		

func get_narrator() -> NarratorUI:
	return _narrator

func get_original_narrator_position() -> Vector2:
	return _original_narrator_position

func get_restart_button_position() -> Vector2:
	return _restart_button_original_position

var _pin_loader: BackgroundResourceLoader
func load_pins(pins_dict: Dictionary) -> void:
	# Start loading pins in background
	_pin_loader = BackgroundResourceLoader.new()
	var scene_paths := PoolStringArray([])
	
	var pins := (pins_dict.players + pins_dict.npcs) as Array
	
	for i in pins.size():
		var pin := pins[i] as ArpeegeePin
		scene_paths.push_back(pin.scene_path)
	
	_pin_loader.load(scene_paths)
	get_tree().root.call_deferred('add_child', _pin_loader)

var _started := false
func start(pins: Dictionary) -> void:
	if _started:
		assert(false)
		return
	
	_started = true
	
#	_configure_viewport(_battle_viewport)
#	get_viewport().connect('size_changed', self, '_configure_viewport', [_battle_viewport])
	var layout_scene: PackedScene
	if _is_two_one_layout(pins.npcs.size(), pins.players.size()):
		layout_scene = LayoutTwoOne
	elif _is_one_two_layout(pins.npcs.size(), pins.players.size()):
		layout_scene = LayoutOneTwo
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

#func _process(delta):
#	if Engine.get_idle_frames() % 5 != 0:
#		return
#
#	printt(_battle_viewport.size, _battle_viewport.canvas_transform.get_scale())

func _is_two_one_layout(left_size: int, right_size: int) -> bool:
	return left_size == 2 and right_size == 1

func _is_one_two_layout(left_size: int, right_size: int) -> bool:
	return left_size == 1 and right_size == 2

func _is_one_one_layout(left_size: int, right_size: int) -> bool:
	return left_size == 1 and right_size == 1

func _create_battle_layout(layout_scene: PackedScene, pins: Dictionary) -> BattleLayout:
	var layout := layout_scene.instance() as BattleLayout
	assert(layout, 'must be battle layout')
	_battle_layer.add_child(layout)
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
	
	var item_powerup := pins.item_powerup as PinItemPowerUp
	var item_position := _layout.get_item_position()
	
	connect('pins_dropped', self, '_on_pins_dropped')
	_load_and_drop_pins(players + npcs, right_positions + left_positions, item_powerup, item_position)

func _on_pins_dropped() -> void:
	_wait_for_drop_to_finish(1.0)

func _wait_for_drop_to_finish(wait_sec: float) -> void:
	Music.play_theme()
	
	var tween_to_intro_narration := get_tree().create_tween()
	tween_to_intro_narration.tween_interval(wait_sec)
	tween_to_intro_narration.tween_callback(self, '_do_intro_narration')

func _do_intro_narration() -> void:
	var speaking_tween := create_tween()
	
	speaking_tween.tween_property(_narrator, 'rect_position', _original_narrator_position, 1.5)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	speaking_tween.tween_interval(0.5)
	speaking_tween.tween_callback(_narrator, 'speak_tr', ['NARRATOR_BATTLE_INTRODUCTION_GENERIC', false])
	TweenExtension.pause_until_signal_if_condition(speaking_tween.parallel(), _narrator, 'speaking_ended',
			_narrator, 'is_speaking')
	speaking_tween.tween_callback(self, '_do_start_battle_effects')
	
	speaking_tween.tween_property(_restart_button_holder, 'rect_position:y', _restart_button_holder_original_position.y, 0.5)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _do_start_battle_effects() -> void:
	_turn_manager.connect('battle_ended', self, '_on_battle_ended')
	
	var nodes := NodE.get_children_recursive(_battle_layer, ArpeegeePinNode)
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
	
	var tween := create_tween()
	
	if not disadvantage_dialog.empty():
		tween.tween_callback(_sounds, 'play', ['EnragedHarpy'])
		tween.tween_callback(_narrator, 'speak_tr', [disadvantage_dialog, true])
		_add_speaking_pause(tween, _narrator)
	
	_add_fear_effects(tween)
	
	_add_banan_effects(tween)
	
	_add_koboldio_paladin_friendly_effects(tween)
	
	_add_fishguy_stroking_paladins_hair(tween)
	
	_add_monster_boost_if_against_paladin_and_white_mage(tween)
	
	_add_hats_if_all_pins_uncommon(tween)
	
	_add_sparkles_if_all_pins_rare(tween)
	
	tween.tween_callback(self, '_start_battle', [nodes])

func _add_speaking_pause(tween: SceneTreeTween, narrator: NarratorUI) -> void:
	TweenExtension.pause_until_signal_if_condition(tween, narrator,
			'speaking_ended', _narrator, 'is_speaking')

func _add_sparkles_if_all_pins_rare(animation: SceneTreeTween) -> void:
	var pins := _turn_manager.get_pins()
	for p in pins:
		var pin := p as ArpeegeePinNode
		if pin.resource.rarity != ArpeegeePin.Rarity.Rare:
			return
	
	animation.tween_callback(_narrator, 'speak_tr', ['NARRATOR_ALL_PIN_RARE_SPARKLE', true])
	_add_speaking_pause(animation, _narrator)
	
	animation.tween_interval(0.35)
	for p in pins:
		var rare_sparkles := NodE.get_child(p, RareSparkles) as RareSparkles
		animation.tween_callback(rare_sparkles, 'enable')

func _add_hats_if_all_pins_uncommon(animation: SceneTreeTween) -> void:
	var pins := _turn_manager.get_pins()
	for p in pins:
		var pin := p as ArpeegeePinNode
		if pin.resource.rarity != ArpeegeePin.Rarity.Uncommon:
			return
	
	animation.tween_callback(_narrator, 'speak_tr', ['NARRATOR_ALL_PINS_UNCOMMON_HATS', true])
	_add_speaking_pause(animation, _narrator)
	
	animation.tween_interval(0.35)
	
	var pin_indices := range(pins.size())
	pin_indices.shuffle()
	for i in pin_indices:
		var pin := pins[i] as Node
		var top_hat := NodE.get_child(pin, TopHatter) as TopHatter
		animation.tween_callback(top_hat, 'enable', [i % 3])
		

func _add_monster_boost_if_against_paladin_and_white_mage(animation: SceneTreeTween) -> void:
	var paladin := _get_arpeegee_by_file('paladin.tscn')
	if not paladin:
		return
	
	var white_mage := _get_arpeegee_by_file('white_mage.tscn')
	if not white_mage:
		return
	
	animation.tween_interval(0.5)
	
	for n in _turn_manager.get_npcs():
		var status_effect := StatusEffect.new()
		status_effect.is_ailment = false
		status_effect.stack_count = 1
		status_effect.tag = StatusEffectTag.BoostAgainstPaladinWhiteMage
		
		var attack := _create_stat_modifier_multiplier(StatModifier.Type.Attack, 1.5)
		var defence := _create_stat_modifier_multiplier(StatModifier.Type.Defence, 1.5)
		var attack_magic := _create_stat_modifier_multiplier(StatModifier.Type.MagicAttack, 1.5)
		var defence_magic := _create_stat_modifier_multiplier(StatModifier.Type.MagicDefence, 1.5)
		
		NodE.add_children(status_effect, [attack, defence, attack_magic, defence_magic])
		
		var effects_list := NodE.get_child(n, StatusEffectsList)
		animation.tween_callback(effects_list, 'add_instance', [status_effect])
		
		animation.tween_interval(0.35)
	
	animation.tween_callback(_narrator, 'speak_tr', ['NARRATOR_ANY_MONSTER_VS_PALADIN_WHITE_MAGE', true])
	_add_speaking_pause(animation, _narrator)

func _create_stat_modifier_multiplier(type: int, multiplier: float) -> StatModifier:
	var stat_modifier := StatModifier.new()
	stat_modifier.type = type
	stat_modifier.multiplier = multiplier
	
	return stat_modifier

func _add_fishguy_stroking_paladins_hair(animation: SceneTreeTween) -> void:
	var fishguy := _get_arpeegee_by_file('fishguy.tscn')
	if not fishguy:
		return
	
	var paladin := _get_arpeegee_by_file('paladin.tscn')
	if not paladin:
		return
	
	animation.tween_interval(0.5)
	
	var target_position := ActionUtils.get_closest_adjecent_position(fishguy, paladin) + fishguy.global_position
	
	ActionUtils.add_walk(animation, fishguy, fishguy.global_position, target_position, 15.0, 5)
	
	var fishguy_sprite_switcher := NodE.get_child(fishguy, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(fishguy_sprite_switcher, 'change', ['dance'])
	
	animation.tween_callback(_narrator, 'speak_tr', ['NARRATOR_FISHGUY_STROKES_PALADIN_HAIR', true])
	_add_speaking_pause(animation, _narrator)
	
	animation.tween_interval(0.5)
	
	var sparkle_abilities := get_tree().get_nodes_in_group('sparkle_ability')
	for s in sparkle_abilities:
		if not s.has_method('boost_from_combing'):
			return
		s.boost_from_combing()
	
	animation.tween_callback(fishguy_sprite_switcher, 'change', ['idle'])
	ActionUtils.add_walk(animation, fishguy, target_position, fishguy.global_position, 15.0, 5)

func _add_koboldio_paladin_friendly_effects(animation: SceneTreeTween) -> void:
	var koboldio := _get_arpeegee_by_file('koboldio.tscn')
	if not koboldio:
		return
	
	var paladin := _get_arpeegee_by_file('paladin.tscn')
	if not paladin:
		return
	
	animation.tween_callback(_narrator, 'speak_tr', ['NARRATOR_KOBOLDIO_FRIENDLY_PALADIN', true])
	_add_speaking_pause(animation, _narrator)

func _add_banan_effects(animation: SceneTreeTween) -> void:
	var banan := _get_arpeegee_by_file('banan.tscn')
	if not banan:
		return
	
	var white_mage := _get_arpeegee_by_file('white_mage.tscn')
	if not white_mage:
		return
	
	EffectFunctions.add_banan_in_love_narration_and_effect(banan, white_mage, _narrator, animation)
	_add_speaking_pause(animation, _narrator)

func _add_fear_effects(animation: SceneTreeTween) -> void:
	if _get_arpeegee_by_file('hunter.tscn') != null:
		for file in ['drago.tscn', 'blobbo.tscn', 'koboldio.tscn']:
			var pin := _get_arpeegee_by_file(file)
			if not pin:
				continue
			
			var fear_effect := EffectFunctions.create_fear_status_effect()
			var list := NodE.get_child(pin, StatusEffectsList) as StatusEffectsList
			list.add_instance(fear_effect)
			EffectFunctions.add_fear_narration_and_effect(pin, _narrator, animation)
			_add_speaking_pause(animation, _narrator)

func _get_arpeegee_by_file(file: String) -> ArpeegeePinNode:
	for pin in _turn_manager.get_pins():
		if pin.filename.get_file() == file:
			return pin
		
	return null

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
	#for n in nodes:
	#	_narrator.watch(n)
	_turn_manager.step_turn()

func _load_and_drop_pins(pins: Array, positions: Array, item: Node2D, item_position) -> void:
	
	assert(_pin_loader)
	
	# do tween for waiting on it
	var tween := create_tween()
	TweenExtension.pause_until_signal_if_condition(tween, _pin_loader, 'finished',
			_pin_loader, 'is_busy')
	tween.tween_callback(self, '_drop_pins', [positions, pins, item, item_position,
			_pin_loader])
	
	_pin_loader = null

var _position_control_to_pin_turn_index := {}
func _drop_pins(positions: Array, pins: Array, item: PinItemPowerUp, item_position: Control,
		loader: BackgroundResourceLoader) -> void:
	
	var drop_times := [0.0, 0.05, 0.1, 0.15, 0.2]
	drop_times.shuffle()
	
	var pin_resources := loader.result as Array
	for i in positions.size():
		var pin := pins[i] as ArpeegeePin
		
		var pin_node_scene := pin_resources[i] as PackedScene
		var pin_node := pin_node_scene.instance() as ArpeegeePinNode
		
		var control := positions[i] as Control
		control.add_child(pin_node)
		var position := control.get_global_rect().get_center()
		
		pin_node.global_position = position + Vector2.UP * 900.0
		
		_add_pin_shadow(control)
		
		pin_node.emit_stars()
		
		var drop_tween := get_tree().create_tween()
		drop_tween.tween_interval(drop_times[i])
		drop_tween.tween_callback(_sounds, 'play', ['ShimmerArpeegees'])
		drop_tween.tween_property(pin_node, 'global_position:y', position.y, 0.7)\
			.set_ease(Tween.EASE_IN)\
			.set_trans(Tween.TRANS_CUBIC)
		drop_tween.tween_callback(pin_node, 'post_drop_initialization')
	
	if item:
		_battle_layer.add_child(item)
		var position := item_position.get_global_rect().get_center()
		
		item.global_position = position + Vector2.UP * 1000.0
		
		var drop_tween := get_tree().create_tween()
		drop_tween.tween_interval(drop_times[positions.size()])
		drop_tween.tween_property(item, 'global_position:y', position.y, 1.0)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_BOUNCE)
	
	loader.queue_free()
	emit_signal('pins_dropped')


func _add_pin_shadow(position: Control) -> void:
	if not position:
		assert(false)
		return
	
	var pin_shadow := preload('res://src/resources/arpeegee_pins/pin_shadow.tscn').instance() as PinShadow
	var parent := position.get_parent() as Node
	parent.add_child(pin_shadow)
	parent.move_child(pin_shadow, 0)
	
	pin_shadow.attach_position(position)

func _input(input: InputEvent) -> void:
	var mouse_button := input as InputEventMouseButton
	if not mouse_button:
		return
	
	if mouse_button.pressed and mouse_button.button_index == BUTTON_LEFT:
		_narrator.speed_up_page()
