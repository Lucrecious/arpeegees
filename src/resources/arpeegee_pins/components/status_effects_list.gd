class_name StatusEffectsList
extends Node2D

signal effect_added_or_removed()
signal effect_added(effect)
signal effect_removed(effect)

func add(effect_name: String) -> void:
	var effect := StatusEffects.instance(effect_name)
	add_instance(effect)

func add_instance(instance: StatusEffect) -> void:
	add_child(instance)
	instance.connect('tree_exited', self, '_on_effect_tree_exited', [instance], CONNECT_ONESHOT)
	
	emit_signal('effect_added', instance)
	emit_signal('effect_added_or_removed')

func _on_effect_tree_exited(effect: StatusEffect) -> void:
	emit_signal('effect_removed', effect)
	emit_signal('effect_added_or_removed')
