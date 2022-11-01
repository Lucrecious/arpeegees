class_name ArpeegeePinNode
extends Node2D

export(String) var nice_name := 'Arpeegee'

export(Resource) var _resource_set: Resource = null

onready var resource := _resource_set as ArpeegeePin

onready var _particles := get_node_or_null('Particles') as CPUParticles2D

func _ready() -> void:
	if not resource:
		print_debug('warning: resource missing')

func emit_stars() -> void:
	if not _particles:
		return
	
	_particles.emitting = true

func post_drop_initialization() -> void:
	stop_star_emission()

func stop_star_emission() -> void:
	if not _particles:
		return
	_particles.emitting = false

