class_name BreathFire
extends Node


func breath_fire(animation: SceneTreeTween) -> void:
	var sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['bite'])
	
	var particles := sprite_switcher.sprite('bite').get_child(0) as CPUParticles2D
	animation.tween_callback(particles, 'set', ['emitting', true])
	
	var sounds := NodE.get_sibling(self, SoundsComponent)
	animation.tween_callback(sounds, 'play', ['Fire'])
	
	animation.tween_interval(2.0)
	
	animation.tween_callback(particles, 'set', ['emitting', false])
	animation.tween_callback(particles, 'set', ['visible', false])
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(self, 'queue_free')
