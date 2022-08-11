class_name StatusEffectsList
extends Node2D

func add(effect_name: String) -> void:
	var effect := StatusEffects.instance(effect_name)
	add_child(effect)

func add_instance(instance: Node) -> void:
	add_child(instance)
