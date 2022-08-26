class_name ExplosionParticles
extends CPUParticles2D

func _ready() -> void:
	emitting = true
	
	var tween := create_tween()
	tween.tween_interval(lifetime + 0.5)
	tween.tween_callback(self, 'queue_free')
