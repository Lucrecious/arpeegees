extends Node2D

signal text_triggered(translation_key)

var _blocked := false

func pin_action() -> PinAction:
	return load('res://src/resources/actions/armadillo_stance_monk.tres') as PinAction

func is_blocked() -> bool:
	return _blocked

func run(actioner: Node2D, object: Object, callback: String) -> void:
	assert(not _blocked)
	
	var status_effects_list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var bounds := NodE.get_child(actioner, REferenceRect) as REferenceRect
	var sounds := NodE.get_child_by_name(actioner, 'Sounds')
	
	_blocked = true
	
	var animation := create_tween()
	
	animation.tween_interval(1.0)
	
	animation.tween_callback(self, '_replace_idle_with_armadillo_stance', [sprite_switcher])
	animation.tween_callback(sounds, 'play', ['ArmadilloStance'])
	
	var shield_vfx := VFX.shield_vfx()
	animation.tween_callback(get_parent(), 'add_child', [shield_vfx])
	animation.tween_callback(shield_vfx, 'set',
			['global_position', bounds.global_rect().get_center()])
	
	var status_effect := _create_armadillo_stance_status_effect()
	
	animation.tween_callback(status_effects_list, 'add_instance', [status_effect])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_ARMADILLO_STANCE_USE')
	
	animation.tween_interval(0.5)
	animation.tween_callback(object, callback)

func _replace_idle_with_armadillo_stance(sprite_switcher: SpriteSwitcher) -> void:
	sprite_switcher.swap_map('idle', 'armadillostance')

func _create_armadillo_stance_status_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.ArmadilloStance
	
	var defensive_stat := StatModifier.new()
	defensive_stat.type = StatModifier.Type.Defence
	defensive_stat.multiplier = 2.0
	
	var magic_defensive_stat := StatModifier.new()
	magic_defensive_stat.type = StatModifier.Type.MagicDefence
	magic_defensive_stat.multiplier = 2.0
	
	var attack_stat := StatModifier.new()
	attack_stat.type = StatModifier.Type.Attack
	attack_stat.multiplier = 0.5
	
	NodE.add_children(status_effect, [defensive_stat, magic_defensive_stat, attack_stat])
	
	return status_effect
