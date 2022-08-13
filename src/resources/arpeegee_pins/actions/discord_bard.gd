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
	
	var status_effect := StatusEffect.new()
	var discord_effect := DiscordStartTurnEffect.new()
	status_effect.add_child(discord_effect)
	
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	animation.tween_callback(sprite_switcher, 'change', ['discord'])
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_DISCORD_USE_1')
	animation.tween_interval(0.2)
	
	var hit_position := ActionUtils.add_projectile_shot(animation,
			spawn_position_hint, target,
			1.2, projectile_scene)
	ActionUtils.add_damage(animation, target, attack_damage)
	animation.tween_callback(VFX, 'physical_impactv', [actioner, hit_position])
	animation.tween_callback(target_status_effects, 'add_instance', [status_effect])
	
	animation.tween_interval(1.0)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	animation.tween_interval(1.0)
	
	animation.tween_callback(object, callback)
