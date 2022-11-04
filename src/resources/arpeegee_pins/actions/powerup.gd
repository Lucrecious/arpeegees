extends Node2D

signal text_triggered(text_triggered)

var _uses := 0

func pin_action() -> PinAction:
	return load('res://src/resources/actions/monk_powerup.tres') as PinAction

func is_blocked() -> bool:
	return _uses >= 3

func run(actioner: Node2D, object: Object, callback: String) -> void:
	_uses += 1
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var status_effects_list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	var sounds := NodE.get_child_by_name(actioner, 'Sounds')
	
	var status_effect := _create_focus_ki_status_effect()
	
	var tween := get_tree().create_tween()
	tween.tween_callback(sprite_switcher, 'change', ['powerup'])
	
	tween.tween_callback(sounds, 'play', ['FocusKiCharge'])
	
	tween.tween_callback(status_effects_list, 'add_instance', [status_effect])
	
	tween.tween_interval(0.75)
	
	ActionUtils.add_text_trigger(tween, self, 'NARRATOR_FOCUS_KI_USE_1')
	
	tween.tween_interval(0.75)
	
	tween.tween_callback(sprite_switcher, 'change', ['idle'])
	tween.tween_callback(object, callback)

func _create_focus_ki_status_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 3
	status_effect.tag = StatusEffectTag.FocusKi
	
	var stat_modifier := StatModifier.new()
	stat_modifier.type = StatModifier.Type.Attack
	stat_modifier.multiplier = 1.5
	
	status_effect.add_child(stat_modifier)
	NodE.add_children(status_effect, Aura.create_power_up_auras())
	NodE.add_children(status_effect, VFX.power_up_initial_explosion())
	
	return status_effect
