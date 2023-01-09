extends Node2D

signal text_triggered(narration_key)

var is_this_food := false

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/beatboxin_bard_mandolinless.tres')

func run(actioner: Node2D, object: Object, callback: String) -> void:
	var scream_action := NodE.get_sibling_by_name(self, 'Scream') as Node2D
	assert(scream_action)
	scream_action.boosted = true
	
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	if is_this_food and IsThisFood.too_sad_to_attack():
		IsThisFood.add_is_this_food(animation, self, object, callback)
		return
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['beatbox'])
	
	var sounds := NodE.get_child(actioner, SoundsComponent) as SoundsComponent
	animation.tween_callback(sounds, 'play', ['Beatbox'])
	animation.tween_callback(Music, 'pause_fade_out')
	
	var root_sprite := Components.root_sprite(actioner)
	var skew_stepper := JuiceSteppers.SkewBackAndForth.new(animation, root_sprite.material)
	skew_stepper.offset = 0.05
	skew_stepper.offset_to_home_sec = 0.2
	skew_stepper.between_offsets_sec = 0.5
	
	for i in 6:
		skew_stepper.step()
	
	skew_stepper.finish()
	
	ActionUtils.add_text_trigger_limited(animation, self, 'NARRATOR_BEATBOXIN_USE')
	
	animation.tween_interval(1.0)
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	animation.tween_callback(Music, 'unpause_fade_in')
	
	animation.tween_interval(0.5)
	animation.tween_callback(object, callback)


