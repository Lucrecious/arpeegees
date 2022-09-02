extends Node2D

signal text_triggered(translation_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/chikara_panchi_monk.tres') as PinAction

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var status_effects_list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	
	var animation := create_tween()
	animation.tween_interval(1.0)
	
	animation.tween_callback(sprite_switcher, 'swap_map', ['idle', 'powerup'])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_CHIKARA_PANCHI_USE_START')
	
	var chikara_panchi_effect := ChikaraPanchiEffect.new()
	chikara_panchi_effect.sprite_switcher = sprite_switcher
	chikara_panchi_effect.actioner = actioner
	chikara_panchi_effect.target = target
	chikara_panchi_effect.hint_position = get_child(0)
	animation.tween_callback(status_effects_list, 'add_as_children', [[chikara_panchi_effect]])
	
	animation.tween_interval(0.5)
	
	animation.tween_callback(object, callback)
