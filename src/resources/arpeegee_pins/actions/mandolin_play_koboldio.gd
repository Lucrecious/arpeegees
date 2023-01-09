extends Node2D

signal text_triggered(narration_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/mandolin_play_koboldio.tres')

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	animation.tween_callback(Music, 'pause_fade_out')
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['play'])
	
	var sounds := NodE.get_child(actioner, SoundsComponent)
	animation.tween_callback(sounds, 'play', ['Play'])
	
	var root_sprite := Components.root_sprite(actioner)
	var skew_stepper := JuiceSteppers.SkewBackAndForth.new(animation, root_sprite.material)
	skew_stepper.offset = 0.1
	skew_stepper.offset_to_home_sec = 0.5
	skew_stepper.between_offsets_sec = 1.0
	skew_stepper.squish_bottom = 0.9
	
	for i in 4:
		skew_stepper.step()
		_add_explosion(animation, actioner)
		animation.tween_interval(0.5)
	
	skew_stepper.finish()
	
	for t in targets:
		var list := NodE.get_child(t, StatusEffectsList) as StatusEffectsList
		animation.tween_callback(list, 'add_instance', [_create_status_effect()])
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	ActionUtils.add_text_trigger_limited(animation, self, 'NARRATOR_MANDOLIN_PLAY_USE')
	
	animation.tween_callback(Music, 'unpause_fade_in')
	
	animation.tween_interval(0.35)
	
	animation.tween_callback(object, callback)

func _add_explosion(animation: SceneTreeTween, explosion_parent: Node2D) -> void:
	var explosion := VFX.note_explosion(false)
	animation.tween_callback(explosion_parent, 'add_child', [explosion])

func _create_status_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.tag = StatusEffectTag.MandolinPlay
	status_effect.is_ailment = true
	status_effect.stack_count = 2
	
	var defence_down := StatModifier.new()
	defence_down.type = StatModifier.Type.Defence
	defence_down.add_amount = -1
	
	var magic_defence_down := StatModifier.new()
	magic_defence_down.type = StatModifier.Type.MagicDefence
	magic_defence_down.add_amount = -1
	
	NodE.add_children(status_effect, [defence_down, magic_defence_down])
	
	return status_effect
