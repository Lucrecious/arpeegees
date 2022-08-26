extends Node2D

func pin_action() -> PinAction:
	return load('res://src/resources/actions/monk_powerup.tres') as PinAction

func run(actioner: Node2D, object: Object, callback: String) -> void:
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var status_effects_list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	
	var status_effect := StatusEffect.new()
	status_effect.add_to_group('__focus_ki_status_effect')
	var stat_modifier := StatModifier.new()
	stat_modifier.type = StatModifier.Type.Attack
	stat_modifier.multiplier = 1.5
	var status_effect_children := [stat_modifier]
	status_effect_children += Aura.create_power_up_auras()
	status_effect_children += VFX.power_up_initial_explosion()
	for c in status_effect_children:
		status_effect.add_child(c)
	
	var tween := get_tree().create_tween()
	tween.tween_callback(sprite_switcher, 'change', ['powerup'])
	tween.tween_callback(status_effects_list, 'add_instance', [status_effect])
	tween.tween_interval(1.3)
	tween.tween_callback(sprite_switcher, 'change', ['idle'])
	tween.tween_callback(object, callback)
