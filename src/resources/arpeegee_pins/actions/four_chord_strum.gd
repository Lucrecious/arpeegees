extends Node2D

signal text_triggered(translation_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/four_chord_strum.tres')

func run(actioner: Node2D, object: Object, callback: String) -> void:
	var actions := NodE.get_child(actioner, PinActions) as PinActions
	var heckin_good_song := NodE.get_child(actions, HeckinGoodSongPinAction) as HeckinGoodSongPinAction
	var root_sprite := Components.root_sprite(actioner)
	var sounds := NodE.get_child(actioner, SoundsComponent) as SoundsComponent
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher

	var explosion_parent := NodE.get_child_by_group(actioner, 'aura_hint_position') as Node2D
	if not explosion_parent:
		explosion_parent = actioner

	heckin_good_song.buffed_from_four_chord_strum = true
	
	var animation := create_tween()
	animation.tween_interval(0.5)
	
	animation.tween_callback(sprite_switcher, 'change', ['heckingoodsong'])
	
	animation.tween_callback(sounds, 'play', ['ChordStrum'])
	
	var skew_stepper := JuiceSteppers.SkewBackAndForth.new(animation, root_sprite.material)
	skew_stepper.offset = 0.1
	skew_stepper.offset_to_home_sec = 0.5
	skew_stepper.between_offsets_sec = 1.0
	skew_stepper.squish_bottom = 0.9
	
	for i in 4:
		skew_stepper.step()
		_add_explosion(animation, explosion_parent)
		animation.tween_interval(0.5)
	
	skew_stepper.finish()
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_FOUR_CHORD_STRUM_USE_1')
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_interval(0.5)
	animation.tween_callback(object, callback)

func _add_explosion(animation: SceneTreeTween, explosion_parent: Node2D) -> void:
	var explosion := VFX.note_explosion(false)
	animation.tween_callback(explosion_parent, 'add_child', [explosion])
