class_name StatusEffectsList
extends Node2D

signal effect_added_or_removed()

func add(effect_name: String) -> void:
	var effect := StatusEffects.instance(effect_name)
	add_child(effect)
	effect.connect('tree_exited', self, '_on_effect_tree_exited', [], CONNECT_ONESHOT)
	
	emit_signal('effect_added_or_removed')

func add_instance(instance: StatusEffect) -> void:
	add_child(instance)
	instance.connect('tree_exited', self, '_on_effect_tree_exited', [], CONNECT_ONESHOT)
	
	emit_signal('effect_added_or_removed')

func _on_effect_tree_exited() -> void:
	emit_signal('effect_added_or_removed')
