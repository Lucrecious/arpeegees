extends Node2D

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/discord_bard.tres')

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var target_status_effects := NodE.get_child(target, StatusEffectsList) as StatusEffectsList
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var attack_damage := ActionUtils.damage_with_factor(modified_stats.attack, 0.5)
	
	var status_effect := StatusEffect.new()
	var start_turn_damage_effect := StartTurnDamageStatusEffect.new()
	start_turn_damage_effect.damage_per_run = attack_damage
	start_turn_damage_effect.runs_alive = 1
	status_effect.add_child(start_turn_damage_effect)
	
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	animation.tween_callback(sprite_switcher, 'change', ['discord'])
	animation.tween_callback(target_status_effects, 'add_instance', [status_effect])
	animation.tween_interval(0.5)
	
	if modified_stats:
		ActionUtils.add_damage(animation, target, attack_damage)
	else:
		assert(false)
	
	animation.tween_interval(1.0)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	animation.tween_interval(1.0)
	
	animation.tween_callback(object, callback)
