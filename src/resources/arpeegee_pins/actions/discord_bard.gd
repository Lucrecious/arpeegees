extends Node2D

signal text_triggered(translation_key)

export(String) var spawn_position_hint_node := 'SpawnPositionHint'
export(PackedScene) var projectile_scene: PackedScene = null

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/discord_bard.tres')

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var target_status_effects := NodE.get_child(target, StatusEffectsList) as StatusEffectsList
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var attack_damage := ActionUtils.damage_with_factor(modified_stats.attack, 0.5)
	var spawn_position_hint := get_node(spawn_position_hint_node).global_position as Vector2
	var root_sprite := NodE.get_child(actioner, RootSprite) as RootSprite
	
	var status_effect := StatusEffect.new()
	var discord_effect := DiscordStartTurnEffect.new()
	status_effect.add_child(discord_effect)
	
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	animation.tween_callback(sprite_switcher, 'change', ['discord'])
	
	for i in 3:
		var skew_start := 0.0
		var skew_end := 0.0
		var skew_sec := 0.5
		match i:
			0:
				skew_start = 0.0
				skew_end = 0.3
				skew_sec = 0.1
			1:
				skew_start = 0.3
				skew_end = -0.3
				skew_sec = 0.25
			2:
				skew_start = -0.3
				skew_end = 0.3
				skew_sec = 0.25
		
		ActionUtils.add_shader_param_interpolation(animation,
				root_sprite.material, 'top_skew', skew_start, skew_end, skew_sec)\
				.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		
		var hit_position := ActionUtils.add_projectile_shot(animation,
				spawn_position_hint, target,
				.8, projectile_scene)
		
		animation.tween_callback(VFX, 'physical_impactv', [actioner, hit_position])
		ActionUtils.add_hurt(animation, target)
	
	ActionUtils.add_damage(animation, target, attack_damage)
	animation.tween_callback(target_status_effects, 'add_instance', [status_effect])
	
	ActionUtils.add_shader_param_interpolation(animation,
			root_sprite.material, 'top_skew', 0.3, 0.0, 0.1)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_DISCORD_USE_1')
	animation.tween_interval(1.0)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	animation.tween_interval(1.0)
	
	animation.tween_callback(object, callback)
