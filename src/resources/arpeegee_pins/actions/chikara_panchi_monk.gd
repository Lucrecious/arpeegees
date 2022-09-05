extends Node2D

signal text_triggered(translation_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/chikara_panchi_monk.tres') as PinAction

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var status_effects_list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var sounds := NodE.get_child_by_name(actioner, 'Sounds')
	
	var animation := create_tween()
	animation.tween_interval(1.0)
	
	var status_effect := _create_chikara_panchi_status_effect(sprite_switcher, actioner, target)
	animation.tween_callback(status_effects_list, 'add_instance', [status_effect])
	
	animation.tween_callback(sprite_switcher, 'swap_map', ['idle', 'powerup'])
	animation.tween_callback(sounds, 'play', ['ChikaraPanchiCharge'])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_CHIKARA_PANCHI_USE_START')
	
	animation.tween_interval(0.5)
	
	animation.tween_callback(object, callback)

func _create_chikara_panchi_status_effect(sprite_switcher: SpriteSwitcher,
		actioner: ArpeegeePinNode, target: ArpeegeePinNode) -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.ChikaraPanchi
	
	var chikara_panchi_effect := ChikaraPanchiEffect.new()
	chikara_panchi_effect.sprite_switcher = sprite_switcher
	chikara_panchi_effect.actioner = actioner
	chikara_panchi_effect.target = target
	chikara_panchi_effect.hint_position = get_child(0)
	
	status_effect.add_child(chikara_panchi_effect)
	
	return status_effect
