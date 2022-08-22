class_name StatusEffectsList
extends Node2D

signal effect_added_or_removed()
signal effect_added(effect)
signal effect_removed(effect)

func add(effect_name: String) -> void:
	var effect := StatusEffects.instance(effect_name)
	add_instance(effect)

func get_all() -> Array:
	return NodE.get_children(self, StatusEffect)

func add_instance(instance: StatusEffect) -> void:
	add_child(instance)
	instance.connect('tree_exited', self, '_on_effect_tree_exited', [instance], CONNECT_ONESHOT)
	
	emit_signal('effect_added', instance)
	emit_signal('effect_added_or_removed')

func add_as_effects(effects: Array) -> void:
	var status_effect := StatusEffect.new()
	for e in effects:
		status_effect.add_child(e)
	
	add_instance(status_effect)

func has_effect_in_status(effect_type) -> Node:
	var error := false
	for status_effect in get_children():
		var effect := NodE.get_child(status_effect, effect_type, error)
		if not effect:
			continue
		return status_effect
	return null

func _on_effect_tree_exited(effect: StatusEffect) -> void:
	emit_signal('effect_removed', effect)
	emit_signal('effect_added_or_removed')
