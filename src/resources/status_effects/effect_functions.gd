class_name EffectFunctions
extends Node


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
