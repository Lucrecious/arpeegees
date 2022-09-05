class_name HeckinGoodSongPinAction
extends Node2D

signal text_triggered(translation_key)

export(String) var spawn_position_hint_node := 'SpawnPositionHint'
export(PackedScene) var projectile_scene: PackedScene = null

onready var _mandolin_nice_chord := $MandolinNiceChord as AudioStreamPlayer

var buffed_from_four_chord_strum := false

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/heckin_good_song.tres')

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var root_sprite := Components.root_sprite(actioner)
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var explosion_parent := NodE.get_child_by_group(actioner, 'aura_hint_position') as Node2D
	if not explosion_parent:
		explosion_parent = actioner
	
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	var skew_stepper := JuiceSteppers.SkewBackAndForth.new(animation, root_sprite.material)
	skew_stepper.offset = 0.3
	skew_stepper.between_offsets_sec = 0.6
	skew_stepper.offset_to_home_sec = 0.5
	
	animation.tween_callback(sprite_switcher, 'change', ['heckingoodsong'])
	animation.tween_callback(_mandolin_nice_chord, 'play')
	
	for i in 2:
		skew_stepper.step()
		_add_explosion(animation, explosion_parent)
		animation.tween_interval(0.5)
	
	for t in targets:
		var status_effects := NodE.get_child(t, StatusEffectsList) as StatusEffectsList
		var status_effect := _create_heckin_good_song_status_effect()
		animation.tween_callback(status_effects, 'add_instance', [status_effect])
	
	if buffed_from_four_chord_strum:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_HECKIN_GOOD_SONG_POWERED_UP_USE_1')
	else:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_HECKIN_GOOD_SONG_USE_1')
	
	for i in 2:
		skew_stepper.step()
		_add_explosion(animation, explosion_parent)
		animation.tween_interval(0.5)
	
	skew_stepper.finish()
	animation.tween_interval(0.5)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)

func _add_explosion(animation: SceneTreeTween, explosion_parent: Node2D) -> void:
	var explosion := VFX.note_explosion(false)
	animation.tween_callback(explosion_parent, 'add_child', [explosion])

func _create_heckin_good_song_status_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.HeckinGoodSong
	
	var heckin_good_song_effect := HeckinGoodSongDancingEffect.new()
	heckin_good_song_effect.power_up()
	var auras := Aura.create_note_auras()
	NodE.add_children(status_effect, auras)
	status_effect.add_child(heckin_good_song_effect)
	
	return status_effect
