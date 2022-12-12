class_name NarratorUI
extends MarginContainer

signal speaking_started()
signal text_started()
signal speaking_ended()

const MAX_LINES_VISIBLE := 3

const LETTERS_PER_SEC := 25.0
const DISSOLVE_IN_SEC := 0.5
const WAIT_BEFORE_FIRST_SENTENCE_SEC := 0.3
const WAIT_BETWEEN_SENTENCES_SEC := 2.0
const DISSOLVE_OUT_SEC := 0.5

var _is_speaking := false
var _queued_text := []
var _is_typing := false

onready var _label := $'%Label' as Label
onready var _narrator_head := $'%Jester' as Node2D
onready var _narrator_sprite_switcher := NodE.get_child(_narrator_head, SpriteSwitcher) as SpriteSwitcher
onready var _textbox := $'%Textbox' as Control
onready var _default_font := theme.default_font

func _ready() -> void:
	assert(_default_font)
	
	_textbox_dissolve_level(0.0)
	
func is_speaking() -> bool:
	return _is_speaking

func watch(node: ArpeegeePinNode) -> void:
	Logger.info('narrator watch %s' % [node.name])
	
	var pin_actions := NodE.get_child(node, PinActions) as PinActions
	pin_actions.connect('action_started_with_action_node', self, '_on_pin_action_started', [pin_actions])
	for p in pin_actions.get_pin_action_nodes(false):
		if p.has_signal('text_triggered'):
			Logger.info('connect text triggered to %s action node' % [p.name])
			p.connect('text_triggered', self, '_on_action_node_text_triggered')
	
	var status_effects := NodE.get_child(node, StatusEffectsList) as StatusEffectsList
	status_effects.connect('effect_added', self, '_on_effect_added')
	status_effects.connect('effect_removed', self, '_on_effect_removed')

func unwatch(node: ArpeegeePinNode) -> void:
	Logger.info('unwatching node %s' % [node.name])
	
	var pin_actions := NodE.get_child(node, PinActions) as PinActions
	pin_actions.disconnect('action_started_with_action_node', self, '_on_pin_action_started')
	
	for p in pin_actions.get_pin_action_nodes(false):
		if p.has_signal('text_triggered'):
			Logger.info('disconnect text triggered from %s action node' % [p.name])
			p.disconnect('text_triggered', self, '_on_action_node_text_triggered')
	
	var status_effects := NodE.get_child(node, StatusEffectsList) as StatusEffectsList
	status_effects.disconnect('effect_added', self, '_on_effect_added')
	status_effects.disconnect('effect_removed', self, '_on_effect_removed')

func _on_action_node_text_triggered(translation_key: String) -> void:
	Logger.info('action node text triggred: %s' % [translation_key])
	var chain := true
	speak_tr(translation_key, chain)

func _on_pin_action_started(action_node: Node2D, _actions: PinActions) -> void:
	var text_key := ''
	
	if text_key.empty():
		return
	
	var chain := false
	speak_tr(text_key, chain)

var _current_tween: SceneTreeTween = null
func speak_tr(translation_key: String, chain: bool) -> void:
	var dialogue := tr(translation_key)
	speak(dialogue, chain)

func speak(text: String, chain: bool) -> void:
	if _current_tween:
		if chain:
			_queued_text.push_back(text)
			return
		
		_current_tween.kill()
		_current_tween = null
		_finished_speaking()
	
	_run_speaking_tween(text, true)

func _run_speaking_tween(text: String, start_signal: bool) -> void:
	var pages := _prepare_text(text)
	
	_current_tween = create_tween()
	_current_tween.tween_method(self, '_textbox_dissolve_level', 0.0, 1.0, DISSOLVE_IN_SEC)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	_label.visible_characters = 0
	_label.text = ''
	
	_current_tween.tween_callback(self, 'emit_signal', ['text_started'])
	_current_tween.parallel().tween_callback(Logger, 'info', ['text_started emitted'])
	
	var has_emotion := false
	for p_i in pages.size():
		var p := pages[p_i] as PoolStringArray
		
		if p.size() == 1 and p[0].begins_with('{') and p[0].ends_with('}'):
			var emotion := p[0].lstrip('{').rstrip('}')
			_current_tween.tween_callback(_narrator_sprite_switcher, 'change', [emotion])
			has_emotion = true
			continue
		elif not has_emotion:
			_current_tween.tween_callback(_narrator_sprite_switcher, 'change', ['talk'])
		
		has_emotion = false
		
		_current_tween.tween_callback(self, '_reset_current_tween_speed_scale', [false])
		_current_tween.tween_callback(self, '_set_is_typing', [true])
		
		var length := 0
		var total_thing := p.join('\n') as String
		_current_tween.tween_callback(_label, 'set', ['text', total_thing])
		_current_tween.tween_callback(_label, 'set', ['visible_characters', 0])
		
		var line_spaces := PoolIntArray([])
		for i in p.size():
			var line := p[i] as String
			var new_line_length := int(line.length() + 1) # + 1 for the new line
			line_spaces.push_back(line.count(' '))
			
			if i >= MAX_LINES_VISIBLE:
				var remove_line_length := int(p[i - MAX_LINES_VISIBLE].length() + 1) # + 1 for new line
				_current_tween.tween_callback(self, '_wrap_lines', [new_line_length, remove_line_length, length])
				length -= remove_line_length
			
			length += new_line_length
			
			_current_tween.tween_method(self, '_set_visible_characters',
					length - new_line_length, length, new_line_length / LETTERS_PER_SEC)
		
		_current_tween.tween_callback(self, '_set_is_typing', [false])
		_current_tween.tween_callback(self, '_reset_current_tween_speed_scale', [true])
		_current_tween.tween_interval(WAIT_BETWEEN_SENTENCES_SEC)
	
	_current_tween.tween_method(self, '_textbox_dissolve_level', 1.0, 0.5, DISSOLVE_OUT_SEC / 2.0)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	
	_current_tween.tween_callback(_narrator_sprite_switcher, 'change', ['neutral'])
	
	_current_tween.tween_callback(_label, 'set', ['visible_characters', 0])
	_current_tween.tween_method(self, '_textbox_dissolve_level', 0.5, 0.0, DISSOLVE_OUT_SEC / 2.0)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	
	_current_tween.tween_callback(self, '_finished_speaking')
	
	_is_speaking = true
	if not start_signal:
		return
	
	Logger.info('speaking_started emitted')
	emit_signal('speaking_started')

var _page_sped_up := false
func speed_up_page() -> void:
	if not _current_tween:
		return
	
	if _is_typing:
		_current_tween.set_speed_scale(4.0)
		Logger.info('speed up page text 4x')
		_page_sped_up = true
	elif not _is_typing and is_speaking():
		_current_tween.set_speed_scale(2.0)
		Logger.info('speed up page text 2x')
		_page_sped_up = true

func _reset_current_tween_speed_scale(before_interval: bool) -> void:
	if not _current_tween:
		return
	
	if _page_sped_up and before_interval:
		Logger.info('reset text speed but faster')
		_current_tween.set_speed_scale(2.0)
	else:
		_current_tween.set_speed_scale(1.0)
		Logger.info('reset text speed to original')
	_page_sped_up = false

func _set_visible_characters(value: int) -> void:
	if value > 0:
		var space_count := _label.text.count(' ', 0, value)
		var newline_count := _label.text.count('\n', 0, value)
		value -= (space_count + newline_count)
	
	_label.visible_characters = value

func _wrap_lines(new_line_length: int, remove_line_length: int, current_sentence_length: int) -> void:
	_label.text = _label.text.right(remove_line_length)
	var characters_shown := current_sentence_length - remove_line_length
	if characters_shown > 0:
		var space_count := _label.text.count(' ', 0, characters_shown)
		var newline_count := _label.text.count('\n', 0, characters_shown)
		characters_shown -= (newline_count + space_count)
	
	_label.visible_characters = characters_shown

func _prepare_text(text: String) -> Array:
	var phrases := Array(STring.split_phrases(text))
	for i in phrases.size():
		var phrase := phrases[i] as String
		if phrase.begins_with('{') and phrase.ends_with('}'):
			phrases[i] = PoolStringArray([phrase])
		else:
			phrases[i] = STring.autowrap(phrase, _label.rect_size.x, _default_font)
	
	return phrases

func _finished_speaking() -> void:
	_is_typing = false
	_textbox_dissolve_level(0.0)
	_label.text = ""
	if _current_tween:
		_current_tween.kill()
		_current_tween = null
	
	if _queued_text.empty():
		_is_speaking = false
		Logger.info('speaking_ended emitted')
		emit_signal('speaking_ended')
		return
	
	_run_speaking_tween(_queued_text.pop_front(), false)

func _textbox_dissolve_level(ratio: float) -> void:
	_textbox.material.set_shader_param('dissolve_value', ratio)

func _on_effect_added(effect: StatusEffect) -> void:
	for child in effect.get_children():
		if not child.has_signal('text_triggered'):
			continue
		
		child.connect('text_triggered', self, '_on_status_effect_text_triggered')

func _on_effect_removed(effect: StatusEffect) -> void:
	for child in effect.get_children():
		if not child.has_signal('text_triggered'):
			continue
		
		if child.is_connected('text_triggered', self, '_on_status_text_triggered'):
			child.disconnect('text_triggered', self, '_on_status_text_triggered')

func _on_status_effect_text_triggered(translation_key: String) -> void:
	var chain := true
	speak_tr(translation_key, chain)

func _set_is_typing(value: bool) -> void:
	if _is_typing == value:
		return
	
	_is_typing = value

func _process(_delta: float) -> void:
	if not _is_typing:
		return
	
	if Engine.get_idle_frames() % 15 != 0:
		return
	
	Sounds.play_new('SpeakingBlip1')
