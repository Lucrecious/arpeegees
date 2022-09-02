extends Node2D

signal text_triggered(translation_key)

func pin_action() -> PinAction:
	return load('res://src/resources/actions/armadillo_stance_monk.tres') as PinAction

func run(actioner: Node2D, object: Object, callback: String) -> void:
	var status_effects_list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var bounds := NodE.get_child(actioner, REferenceRect) as REferenceRect
	
	var animation := create_tween()
	
	animation.tween_interval(1.0)
	
	animation.tween_callback(self, '_replace_idle_with_armadillo_stance', [sprite_switcher])
	
	var shield_vfx := VFX.shield_vfx()
	animation.tween_callback(get_parent(), 'add_child', [shield_vfx])
	animation.tween_callback(shield_vfx, 'set',
			['global_position', bounds.global_rect().get_center()])
	
	var defensive_stat := StatModifier.new()
	defensive_stat.type = StatModifier.Type.Defence
	defensive_stat.multiplier = 2.0
	
	var magic_defensive_stat := StatModifier.new()
	magic_defensive_stat.type = StatModifier.Type.MagicDefence
	magic_defensive_stat.multiplier = 2.0
	
	var attack_stat := StatModifier.new()
	attack_stat.type = StatModifier.Type.Attack
	attack_stat.multiplier = 0.5
	
	animation.tween_callback(status_effects_list, 'add_as_children',
			[[defensive_stat, magic_defensive_stat, attack_stat]])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_ARMADILLO_STANCE_USE')
	
	animation.tween_interval(0.5)
	animation.tween_callback(object, callback)

func _replace_idle_with_armadillo_stance(sprite_switcher: SpriteSwitcher) -> void:
	sprite_switcher.swap_map('idle', 'armadillostance')
