class_name StatusEffect
extends Node2D

var stack_count := 1

var tag := -1

var is_ailment := true

static func queue_free_leave_particles_until_dead(status_effect: StatusEffect) -> void:
	var particles := NodE.get_children(status_effect, CPUParticles2D)
	
	var max_lifetime := 0.0
	
	for p in particles:
		status_effect.remove_child(p)
		status_effect.get_parent().add_child(p)
		p.emitting = false
		max_lifetime = max(p.lifetime, max_lifetime)
	
	status_effect.queue_free()
	
	var queue_free_tween := status_effect.get_parent().create_tween()
	queue_free_tween.tween_interval(max_lifetime * 2.0)
	
	for p in particles:
		queue_free_tween.tween_callback(p, 'queue_free')


func _ready() -> void:
	assert(tag != -1, 'must be set')
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
