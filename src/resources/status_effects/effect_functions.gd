class_name EffectFunctions
extends Node

static func create_burn_status_effect(attack_based: int) -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.Burning
	
	var burn := BurnEffect.new()
	burn.attack_based = attack_based
	status_effect.add_child(burn)
	
	return status_effect

class BurnEffect extends Node:
	signal start_turn_effect_finished()
	
	var attack_based := 1
	
	onready var _pin := NodE.get_ancestor(self, ArpeegeePinNode) as ArpeegeePinNode
	onready var _root_sprite := Components.root_sprite(_pin)
	
	func run_start_turn_effect() -> void:
		var animation := create_tween()
		
		var material := _root_sprite.material as ShaderMaterial
		material.set_shader_param('fill_color', Color.firebrick)
		
		ActionUtils.add_shader_param_interpolation(animation, material, 'color_mix',
				0.0, 0.6, 0.5)
		
		animation.tween_callback(material, 'set_shader_param', ['fill_color', Color.white])
		
		var damage_receiver := NodE.get_child(_pin, DamageReceiver) as DamageReceiver
		var burn_amount := ActionUtils.damage_with_factor(attack_based, 0.3)
		animation.tween_callback(damage_receiver, 'damage',
				[burn_amount, PinAction.AttackType.Normal, false])
		
		animation.tween_callback(self, 'call_deferred',
				['emit_signal', 'start_turn_effect_finished'])

static func bright_sparkles(pin: ArpeegeePinNode) -> void:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 3
	status_effect.tag = StatusEffectTag.BrightSparkles
	
	var modifier := StatModifier.new()
	modifier.type = StatModifier.Type.Critical
	modifier.multiplier = 1.5
	
	status_effect.add_child(modifier)
	var auras := Aura.create_bright_sparkles_aura()
	NodE.add_children(status_effect, auras)
	
	var status_effects_list := NodE.get_child(pin, StatusEffectsList) as StatusEffectsList
	status_effects_list.add_instance(status_effect)
