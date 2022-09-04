class_name DiscordStartTurnEffect
extends Node

const RUNS_ALIVE := 1

signal start_turn_effect_finished()
signal text_triggered(translation_key)

onready var runs_alive := RUNS_ALIVE
onready var _pin := NodE.get_ancestor(self, ArpeegeePinNode) as ArpeegeePinNode
onready var _modified_stats := NodE.get_child(_pin, ModifiedPinStats) as ModifiedPinStats

var _notes_pairs := []

func _ready() -> void:
	var head_position := ActionUtils.get_head_position(_pin)
	
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
	
	var head_position := ActionUtils.get_head_position(_pin)
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_DISCORD_RECOIL_EFFECT')
	
	for notes in _notes_pairs:
		animation.tween_property(notes, 'global_position', head_position, 0.25)\
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		
		animation.tween_callback(notes, 'queue_free')
		ActionUtils.add_hurt(animation, _pin)
		animation.tween_callback(VFX, 'physical_impactv', [_pin, head_position])
		animation.tween_interval(0.3)
	
	ActionUtils.add_damage(animation, _pin,
			ActionUtils.damage_with_factor(_modified_stats.attack, 0.5), PinAction.AttackType.Magic)
	
	runs_alive -= 1
	
	animation.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
	
	if runs_alive > 0:
		return
		
	animation.tween_callback(get_parent(), 'queue_free')
