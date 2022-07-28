class_name ArpeegeePinNode
extends Node2D

export(Resource) var _arpeegee_pin setget __arpeegee_pin_set
func __arpeegee_pin_set(value: Resource) -> void:
	if _arpeegee_pin == value:
		return
	
	_arpeegee_pin = value
	_arpeegee_pin_set(value)

var arpeegee_pin: ArpeegeePin setget _arpeegee_pin_set
func _arpeegee_pin_set(value: ArpeegeePin) -> void:
	if arpeegee_pin == value:
		return
	
	arpeegee_pin = value

onready var _particles := $'%StarParticles' as CPUParticles2D

func emit_stars() -> void:
	_particles.emitting = true

func stop_star_emission() -> void:
	_particles.emitting = false
