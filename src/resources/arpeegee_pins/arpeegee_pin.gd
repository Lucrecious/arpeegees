class_name ArpeegeePinNode
extends Node2D

export(String) var nice_name := 'Arpeegee'

onready var _particles := get_node_or_null('Particles') as CPUParticles2D

func emit_stars() -> void:
	if not _particles:
		return
	
	_particles.emitting = true

func stop_star_emission() -> void:
	if not _particles:
		return
	_particles.emitting = false
