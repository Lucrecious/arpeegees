class_name StatusEffect
extends Node2D

func _ready() -> void:
	_start_emissions()

func _start_emissions() -> void:
	for child in get_children():
		if not child is CPUParticles2D:
			continue
		
		child.emitting = true
