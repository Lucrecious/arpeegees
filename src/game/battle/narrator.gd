class_name NarratorUI
extends MarginContainer

signal speaking_started()
signal speaking_ended()

const NARRATOR_MOUTH_OPEN_TEXTURE := preload('res://assets/ui/narrator/narrator_speaking.png')
const NARRATOR_MOUTH_CLOSED_TEXTURE := preload('res://assets/ui/narrator/narrator_silent.png')
const LETTERS_PER_SEC := 30.0

var _pin_nodes := []
var _is_speaking := false

onready var _label := $'%Label' as Label
onready var _narrator_head := $'%NarratorHead' as TextureRect

func _ready() -> void:
	_narrator_head.texture = NARRATOR_MOUTH_CLOSED_TEXTURE
	
	connect('speaking_started', self, '_start_tween_talking_loop')

func _start_tween_talking_loop() -> void:
	if not _is_speaking:
		return
	
	var tween := get_tree().create_tween()
	tween.tween_callback(_narrator_head, 'set', ['texture', NARRATOR_MOUTH_OPEN_TEXTURE])
	tween.tween_interval(rand_range(.05, .2))
	tween.tween_callback(_narrator_head, 'set', ['texture', NARRATOR_MOUTH_CLOSED_TEXTURE])
	tween.tween_interval(rand_range(.05, .2))
	tween.tween_callback(self, '_start_tween_talking_loop')

func watch(nodes: Array) -> void:
	_pin_nodes = nodes.duplicate()
	
	for n in _pin_nodes:
		var pin_actions := NodE.get_child(n, PinActions) as PinActions
		pin_actions.connect('action_started_with_name', self, '_on_pin_action_started', [pin_actions])

func _on_pin_action_started(action_name: String, _actions: PinActions) -> void:
	var text_key := ''
	if action_name == 'MandolinBash':
		text_key = 'NARRATOR_MANDOLIN_BASH_USE_1'
	elif action_name == 'Dive':
		text_key = 'NARRATOR_DIVE_BOMB_HEAD_USE'
	elif action_name == 'PowerUp':
		text_key = 'NARRATOR_FOCUS_KI_USE_1'
	
	if text_key.empty():
		return
	
	speak_tr(text_key)

var _current_tween: SceneTreeTween = null
func speak_tr(translation_key: String) -> void:
	if _current_tween:
		_current_tween.kill()
		_current_tween = null
		_finished_speaking()
	
	var dialogue := tr(translation_key)
	_speak(dialogue)

func _speak(text: String) -> void:
	var sentences := STring.split_sentences(text)

	_current_tween = get_tree().create_tween()
	_label.visible_characters = 0
	_label.text = ''
	
	for s in sentences:
		_current_tween.tween_callback(_label, 'set', ['text', s])
		_current_tween.tween_callback(_label, 'set', ['visible_characters', 0.0])
		_current_tween.tween_property(_label, 'visible_characters', s.length(), s.length() / LETTERS_PER_SEC)
		_current_tween.tween_interval(1.0)
		_current_tween.tween_callback(_label, 'set', ['visible_characters', 0.0])

	_current_tween.tween_callback(self, '_finished_speaking')
	_current_tween.parallel().tween_callback(self, 'set', ['_current_tween', null])
	
	_is_speaking = true
	emit_signal('speaking_started')

func _finished_speaking() -> void:
	_is_speaking = false
	emit_signal('speaking_ended')
