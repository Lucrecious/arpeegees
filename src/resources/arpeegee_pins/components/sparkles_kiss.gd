class_name SparklesKiss
extends Node


func add_sparkles_kiss(animation: SceneTreeTween, narrator_caller: Object, user: ArpeegeePinNode) -> void:
	var blobbo := get_parent() as Node2D
	
	var sprite_switcher := NodE.get_child(blobbo, SpriteSwitcher) as SpriteSwitcher
	
	animation.tween_interval(1.0)
	
	animation.tween_callback(sprite_switcher, 'change', ['lovesparkles'])
	
	var target_position := ActionUtils.get_closest_adjecent_position(blobbo, user) + blobbo.global_position
	
	ActionUtils.add_walk(animation, blobbo, blobbo.global_position, target_position, 15.0, 5)
	
	animation.tween_interval(0.5)
	
	var hearts := VFX.heart_explosion()
	var hearts_position := NodE.get_child(blobbo, REferenceRect).global_rect().get_center() as Vector2
	
	animation.tween_callback(NodE, 'add_children', [blobbo, hearts])
	
	var health := NodE.get_child(user, Health) as Health
	animation.tween_callback(health, 'heal', [2]) # healing 2 instead of 10% 
	
	animation.tween_interval(1.0)
	
	ActionUtils.add_walk(animation, blobbo, target_position, blobbo.global_position, 15.0, 5)
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	ActionUtils.add_text_trigger(animation, narrator_caller, 'NARRATOR_BLOBBO_KISS_FOR_SPARKLES')
	
	animation.tween_interval(0.5)
