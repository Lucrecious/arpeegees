class_name CapPopper
extends Node2D

func pop(animation: SceneTreeTween) -> void:
	var transformer := get_parent().get_node('DeflatedTransform') as Transformer
	animation.tween_callback(transformer, 'request_transform')
	
	var particles := get_child(0) as CPUParticles2D
	
	animation.tween_callback(particles, 'set', ['emitting', true])
	
	var sounds := NodE.get_sibling(self, SoundsComponent)
	animation.tween_callback(sounds, 'play', ['Spore'])
	
	animation.tween_interval(1.5)
	
	animation.tween_callback(particles, 'set', ['emitting', false])
	
	var pins := get_tree().get_nodes_in_group('arpeegee_pin_node')
	for p in pins:
		var health := NodE.get_child(p, Health) as Health
		if health.current <= 0:
			continue
		
		if get_parent() == p:
			continue
		
		var status_effect := StatusEffect.new()
		status_effect.is_ailment = true
		status_effect.stack_count = 1
		status_effect.tag = StatusEffectTag.Poison
		
		var poison_effect := EffectFunctions.Poison.new()
		status_effect.add_child(poison_effect)
		
		var auras := Aura.create_spore_auras(load('res://assets/sprites/effects/poison_glob.png'), 0.333)
		NodE.add_children(status_effect, auras)
		
		var list := NodE.get_child(p, StatusEffectsList) as StatusEffectsList
		animation.tween_callback(list, 'add_instance', [status_effect])
	
	
