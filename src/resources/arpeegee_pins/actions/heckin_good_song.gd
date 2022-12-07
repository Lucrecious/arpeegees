class_name HeckinGoodSongPinAction
extends Node2D

signal text_triggered(translation_key)

enum Type {
	HeckinGoodSong,
	AnOkaySong,
}

export(Type) var type := Type.HeckinGoodSong
export(String) var sing_frame := ''

var buffed_from_four_chord_strum := false
var is_this_food := false

func pin_action() -> PinAction:
	if type == Type.HeckinGoodSong:
		return preload('res://src/resources/actions/heckin_good_song.tres')
	elif type == Type.AnOkaySong:
		return preload('res://src/resources/actions/an_okay_song_bard_mandolinless.tres')
	else:
		assert(false)
		return preload('res://src/resources/actions/heckin_good_song.tres')

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var root_sprite := Components.root_sprite(actioner)
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var explosion_parent := NodE.get_child_by_group(actioner, 'aura_hint_position') as Node2D
	var sounds := NodE.get_child(actioner, SoundsComponent) as SoundsComponent
	
	if not explosion_parent:
		explosion_parent = actioner
	
	var animation := create_tween()
	
	if is_this_food and IsThisFood.too_sad_to_attack():
		animation.tween_interval(0.35)
		IsThisFood.add_is_this_food(animation, self, object, callback)
		return
	
	animation.tween_callback(Music, 'pause_fade_out')
	
	animation.tween_interval(0.5)
	var skew_stepper := JuiceSteppers.SkewBackAndForth.new(animation, root_sprite.material)
	skew_stepper.offset = 0.3
	skew_stepper.between_offsets_sec = 0.6
	skew_stepper.offset_to_home_sec = 0.5
	
	animation.tween_callback(sprite_switcher, 'change', [sing_frame])
	animation.tween_callback(sounds, 'play', ['HeckinGoodSong'])
	
	for i in 2:
		skew_stepper.step()
		_add_explosion(animation, explosion_parent)
		animation.tween_interval(0.5)
	
	for t in targets:
		var status_effects := NodE.get_child(t, StatusEffectsList) as StatusEffectsList
		var status_effect := _create_heckin_good_song_status_effect()
		animation.tween_callback(status_effects, 'add_instance', [status_effect])
	
	for i in 2:
		skew_stepper.step()
		_add_explosion(animation, explosion_parent)
		animation.tween_interval(0.5)
	
	skew_stepper.finish()
	animation.tween_interval(0.5)
	
	if type == Type.HeckinGoodSong:
		if buffed_from_four_chord_strum:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_HECKIN_GOOD_SONG_POWERED_UP_USE_1')
		else:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_HECKIN_GOOD_SONG_USE_1')
	elif type == Type.AnOkaySong:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_AN_OKAY_SONG_NAME_USE')
	
	animation.tween_callback(Music, 'unpause_fade_in')
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)

func _add_explosion(animation: SceneTreeTween, explosion_parent: Node2D) -> void:
	var explosion := VFX.note_explosion(false)
	animation.tween_callback(explosion_parent, 'add_child', [explosion])

func _create_heckin_good_song_status_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.is_ailment = false
	status_effect.stack_count = 1
	
	if type == Type.HeckinGoodSong:
		status_effect.tag = StatusEffectTag.HeckinGoodSong
	elif type == Type.AnOkaySong:
		status_effect.tag = StatusEffectTag.AnOkaySong
	
	var heckin_good_song_effect := HeckinGoodSongDancingEffect.new()
	if type == Type.HeckinGoodSong:
		heckin_good_song_effect.narration_key = 'NARRATOR_HECKIN_GOOD_SONG_MONSTER_DISTRACTED'
		heckin_good_song_effect.skip_turn_percent = 0.5
		if buffed_from_four_chord_strum:
			heckin_good_song_effect.power_up()
	elif type == Type.AnOkaySong:
		heckin_good_song_effect.narration_key = 'NARRATOR_AN_OKAY_SONG_DISTRACTED'
		heckin_good_song_effect.skip_turn_percent = 0.3
	var auras := Aura.create_note_auras()
	NodE.add_children(status_effect, auras)
	status_effect.add_child(heckin_good_song_effect)
	
	return status_effect
