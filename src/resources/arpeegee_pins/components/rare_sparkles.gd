class_name RareSparkles
extends Node2D

func enable() -> void:
	var sparkle_effect := StatusEffect.new()
	sparkle_effect.is_ailment = false
	sparkle_effect.stack_count = 1
	sparkle_effect.tag = StatusEffectTag.SparkleFromRare
	
	var particles := get_child(0) as CPUParticles2D
	var particles_global_position := particles.global_position
	remove_child(particles)
	
	sparkle_effect.add_child(particles)
	particles.set_deferred('global_position', particles_global_position)
	particles.emitting = true
	
	var status_effects := NodE.get_sibling(self, StatusEffectsList) as StatusEffectsList
	status_effects.add_child(sparkle_effect)
