extends Node2D

signal text_triggered(translation)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/stab_stab_hunter.tres') as PinAction

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	var alive_targets := _get_alive_targets(targets)
	var stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var damage_per_attack := ActionUtils.damage_with_factor(stats.attack, 0.5)
	
	var actioner_position := actioner.global_position
	
	if alive_targets.size() == 1:
		var target := alive_targets[0] as ArpeegeePinNode
		var target_position := actioner_position + ActionUtils.get_closest_adjecent_position(actioner, target)
		ActionUtils.add_walk(animation, actioner,
				actioner.global_position, target_position, 15.0, 5)
		
		animation.tween_interval(0.35)
		
		for i in 2:
			_add_attack_stab(animation, actioner, target, target_position, damage_per_attack,
					'stab%d' % [i + 1])
			
			animation.tween_interval(0.25)
	
	elif alive_targets.size() > 1:
		var target1 := alive_targets[0] as ArpeegeePinNode
		var target1_position := actioner_position + ActionUtils.get_closest_adjecent_position(actioner, target1)
		
		ActionUtils.add_walk(animation, actioner,
				actioner.global_position, target1_position, 15.0, 5)
		
		animation.tween_interval(0.35)
		
		_add_attack_stab(animation, actioner, target1, target1_position, damage_per_attack, 'stab1')
		
		var target2 := alive_targets[1] as ArpeegeePinNode
		var target2_position := actioner_position + ActionUtils.get_closest_adjecent_position(actioner, target2)
		
		ActionUtils.add_walk(animation, actioner,
				target1_position, target2_position, 15.0, 2)
		
		_add_attack_stab(animation, actioner, target2, target2_position, damage_per_attack, 'stab2')
	
	ActionUtils.add_text_trigger_limited(animation, self, 'NARRATOR_STAB_STAB_USE')
	
	animation.tween_interval(0.2)
	animation.tween_property(actioner, 'global_position', actioner.global_position, 0.1)
	
	animation.tween_callback(object, callback)

func _add_attack_stab(animation: SceneTreeTween, actioner: ArpeegeePinNode, target: ArpeegeePinNode,
		target_position: Vector2, damage_amount: int, frame: String) -> void:
	
	animation.tween_callback(Sounds, 'play', ['WindUpAttack'])
	ActionUtils.add_wind_up(animation, actioner, target_position, 1)
	
	ActionUtils.add_stab(animation, actioner, target_position)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', [frame])
	
	animation.tween_callback(Sounds, 'play', ['Slash'])
	ActionUtils.add_attack(animation, actioner, target, damage_amount)
	
	var impact_position := NodE.get_child(target, REferenceRect).global_rect().get_center() as Vector2
	animation.tween_callback(VFX, 'physical_impactv', [target, impact_position])
	
	ActionUtils.add_shake(animation, actioner, target_position, Vector2(1, 0), 5.0, .35)
	
	animation.tween_interval(0.2)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])

func _get_alive_targets(targets: Array) -> Array:
	var alive := []
	
	for t in targets:
		var health := NodE.get_child(t, Health) as Health
		if health.current <= 0:
			continue
		
		alive.push_back(t)
	
	return alive
