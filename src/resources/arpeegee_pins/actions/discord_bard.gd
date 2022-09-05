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
	var sounds := NodE.get_child(actioner, SoundsComponent) as SoundsComponent
	
	var status_effect := _create_discord_status_effect(actioner)
	
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	animation.tween_callback(sprite_switcher, 'change', ['discord'])
	
	var skew_stepper := JuiceSteppers.SkewBackAndForth.new(animation, root_sprite.material)
	skew_stepper.offset = 0.3
	skew_stepper.offset_to_home_sec = 0.25
	skew_stepper.between_offsets_sec = 0.5
	
	animation.tween_callback(sounds, 'play_random', ['DiscordSong', 2])
	
	for i in 3:
		skew_stepper.step()
		add_projectile_and_vfx(animation, actioner, target, spawn_position_hint)
		animation.tween_callback(sounds, 'play', ['DiscordHit%d' % (i + 1)])
	
	ActionUtils.add_attack(animation, actioner, target, attack_damage)
	animation.tween_callback(target_status_effects, 'add_instance', [status_effect])
	
	skew_stepper.finish()
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_DISCORD_USE_1')
	animation.tween_interval(1.0)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	animation.tween_interval(1.0)
	
	animation.tween_callback(object, callback)

func add_projectile_and_vfx(animation: SceneTreeTween, actioner: Node2D, target: Node2D, spawn_position: Vector2) -> Vector2:
	var hit_position := ActionUtils.add_projectile_shot(animation,
			spawn_position, target,
			.8, projectile_scene)
	
	animation.tween_callback(VFX, 'physical_impactv', [actioner, hit_position])
	ActionUtils.add_hurt(animation, target)
	
	return hit_position

func _create_discord_status_effect(actioner: ArpeegeePinNode) -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.tag = StatusEffectTag.Discord
	status_effect.stack_count = 1
	
	var discord_effect := DiscordStartTurnEffect.new()
	discord_effect.bard_pin = actioner
	status_effect.add_child(discord_effect)
	
	return status_effect
