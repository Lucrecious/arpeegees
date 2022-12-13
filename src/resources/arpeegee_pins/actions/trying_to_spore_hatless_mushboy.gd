extends Node2D

signal text_triggered(translation)

var _uses := 0

var _is_blocked := false
func is_blocked() -> bool:
	return _is_blocked

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/trying_to_spore_hatless_mushboy.tres')

func run(actioner: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['tryingtospore'])
	
	var sounds := NodE.get_child(actioner, SoundsComponent)
	animation.tween_callback(sounds, 'play', ['SporeTry'])
	
	var status_effects_list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	animation.tween_callback(status_effects_list, 'add_instance', [_create_getting_angry_effect()])
	
	_uses += 1
	if _uses >= 1 and _uses <= 3:
		var narration_key := 'NARRATOR_TRYING_TO_SPORE_USE_%d' % [_uses]
		ActionUtils.add_text_trigger(animation, self, narration_key)
	
	if _uses >= 3:
		_is_blocked = true
	
	animation.tween_interval(1.5)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)

func _create_getting_angry_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.tag = StatusEffectTag.AngryHatlessMushboy
	status_effect.stack_count = 3
	status_effect.is_ailment = false
	
	var stat_modifier := StatModifier.new()
	stat_modifier.type = StatModifier.Type.Attack
	stat_modifier.add_amount = 1
	print_debug('add amount should be 0.5 but its 1 because only integers for stats right now')
	
	status_effect.add_child(stat_modifier)
	
	return status_effect
