class_name DiscordStartTurnEffect
extends Node

const RUNS_ALIVE := 1

signal start_turn_effect_finished()
signal text_triggered(translation_key)

var narration_key := ''
var damage_factor := 1.0
var bard_pin: ArpeegeePinNode
var _notes_pairs := []
var _bard_sounds: SoundsComponent

onready var runs_alive := RUNS_ALIVE

func _ready() -> void:
	request_ready()
	
	var pin := NodE.get_ancestor(self, ArpeegeePinNode) as ArpeegeePinNode
	
	assert(bard_pin)
	_bard_sounds = NodE.get_child(bard_pin, SoundsComponent) as SoundsComponent
	
	var head_position := ActionUtils.get_head_position(pin)
	
	for i in 3:
		var notes := preload('res://src/vfx/broken_notes.tscn').instance() as VFXNotesPair
		_notes_pairs.push_back(notes)
		add_child(notes)
		notes.global_position = head_position
	
	var direction := Vector2.UP.rotated(randf() * TAU)
	if not direction.is_equal_approx(Vector2.ZERO):
		direction = direction.normalized()
	
	var tween := create_tween()
	tween.set_parallel()
	
	for n in _notes_pairs:
		tween.tween_property(n,
				'global_position', head_position + direction * 150.0, rand_range(0.15, 0.35))\
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
		direction = direction.rotated(TAU / 3.0)

func run_start_turn_effect() -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.75)
	
	var pin := NodE.get_ancestor(self, ArpeegeePinNode) as ArpeegeePinNode
	var modified_stats := NodE.get_child(pin, ModifiedPinStats) as ModifiedPinStats
	var head_position := ActionUtils.get_head_position(pin)
	
	assert(_notes_pairs.size() == 3, 'I only have sounds for 3')
	for i in _notes_pairs.size():
		var notes = _notes_pairs[i]
		animation.tween_property(notes, 'global_position', head_position, 0.25)\
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		
		animation.tween_callback(_bard_sounds, 'play', ['DiscordFollowUpHit%d' % (i + 1)])
		
		animation.tween_callback(notes, 'queue_free')
		ActionUtils.add_hurt(animation, pin)
		animation.tween_callback(VFX, 'physical_impactv', [pin, head_position])
		animation.tween_interval(0.3)
	
	ActionUtils.add_magic_attack(animation, bard_pin, pin,
			ActionUtils.damage_with_factor(modified_stats.attack, 0.5))
	
	ActionUtils.add_text_trigger(animation, self, narration_key)
	runs_alive -= 1
	
	animation.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
	
	if runs_alive > 0:
		return
		
	animation.tween_callback(get_parent(), 'queue_free')
