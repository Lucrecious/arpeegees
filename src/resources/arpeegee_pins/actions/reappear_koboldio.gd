extends Node2D

signal text_triggered(narration_key)

onready var _disappear_action := NodE.get_sibling_by_name(self, 'Disappear')

func is_blocked() -> bool:
	return not _disappear_action.is_blocked()

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/reappear_koboldio.tres')

func run(actioner: Node2D, object: Object, callback: String) -> void:
	var list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	
	_disappear_action.reappear()
	
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	var chance := randf()
	var root_sprite := Components.root_sprite(actioner)
	if false and chance < 0.25:
		
		animation.tween_property(root_sprite, 'modulate:a', 1.0, 1.0)\
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		animation.tween_callback(self, '_remove_disappeared_effect', [list])
		
		animation.tween_interval(1.0)
		
		animation.tween_callback(list, 'add_instance', [_create_come_back_stronger_effect()])
	
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_REAPPEAR_USE_KOBOLDIO')
	
	elif true or chance - 0.25 < 0.25:
		var is_paladin := randf() < 0.5
		var new_scene: PackedScene
		var frame := ''
		if is_paladin:
			new_scene = preload('res://src/resources/arpeegee_pins/paladin.tscn')
			frame = 'paladin'
		else:
			new_scene = preload('res://src/resources/arpeegee_pins/monk.tscn')
			frame = 'monk'
		
		var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
		animation.tween_callback(sprite_switcher, 'change', [frame])
		
		animation.tween_property(root_sprite, 'modulate:a', 1.0, 1.0)\
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		var transformer := NodE.get_child(actioner, Transformer) as Transformer
		transformer.transform_scene = new_scene
		animation.tween_callback(transformer, 'request_transform')
	else:
		# come back as candle
		pass
	
	
	animation.tween_callback(object, callback)

func _remove_disappeared_effect(list: StatusEffectsList) -> void:
	for status_effect in list.get_from_tag(StatusEffectTag.Disappeared):
		status_effect.queue_free()

func _create_come_back_stronger_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 3
	status_effect.is_ailment = false
	status_effect.tag = StatusEffectTag.ReappearedBuff
	
	var enraged_auras := Aura.create_enraged_auras()
	NodE.add_children(status_effect, enraged_auras)
	
	var attack_modifier := StatModifier.new()
	attack_modifier.type = StatModifier.Type.Attack
	attack_modifier.multiplier = 1.5
	
	status_effect.add_child(attack_modifier)
	
	return status_effect
