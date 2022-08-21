class_name StatusEffect
extends Node2D

func _ready() -> void:
	_start_emissions()

func get_modifiers() -> Array:
	var nodes := []
	
	for child in get_children():
		if not child is StatModifier:
			continue
		
		nodes.push_back(child)
	
	return nodes

func get_start_turn_effects() -> Array:
	var nodes := []
	
	for child in get_children():
		if not child.has_method('run_start_turn_effect'):
			continue
		nodes.push_back(child)
	
	return nodes

func get_end_turn_effects() -> Array:
	var nodes := []
	
	for child in get_children():
		if not child.has_method('run_end_turn_effect'):
			continue
		
		nodes.push_back(child)
	
	return nodes

func _start_emissions() -> void:
	for child in get_children():
		if not child is CPUParticles2D:
			continue
		
		child.emitting = true
