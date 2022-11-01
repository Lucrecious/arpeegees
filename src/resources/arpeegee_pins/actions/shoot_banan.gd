extends Node2D

signal text_triggered(narration_key)

var bruised_level := 0

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/shoot_banan.tres') as PinAction

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	
	var material := NodE.get_child(actioner, RootSprite).material as ShaderMaterial
	
	TweenJuice.skew(animation, material, 0.0, -1.0, 1.0)\
			.set_ease(Tween.EASE_OUT).set_ease(Tween.EASE_OUT)
	
	animation.tween_interval(0.35)
	
	TweenJuice.skew(animation, material, -1.0, 0.0, 0.1)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['ShootBanan'])
	
	var banan := sprite_switcher.sprite('ShootBanan').get_child(0) as Node2D
	var banan_original_position := banan.global_position
	var target_box := NodE.get_child(target, REferenceRect) as REferenceRect
	var target_position := target_box.global_rect().get_center()
	
	var relative := target_position - banan.global_position
	
	animation.tween_property(banan, 'global_position',
			banan_original_position + (relative * 0.5) + Vector2.UP * 200.0, 0.15)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	animation.tween_interval(0.2)
	
	animation.tween_property(banan, 'global_position',
			banan_original_position + relative, 0.1)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	var stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var attack_amount := ActionUtils.damage_with_factor(stats.attack, 2.5)
	ActionUtils.add_attack_no_evade(animation, actioner, target, attack_amount)
	
	animation.tween_interval(0.4)
	
	animation.tween_property(banan, 'global_position', banan_original_position, 0.3)
	
	if bruised_level == 0:
		animation.tween_callback(sprite_switcher, 'swap_map', ['idle', 'idle_bruised'])
	elif bruised_level == 1:
		animation.tween_callback(sprite_switcher, 'swap_map', ['idle', 'idle_fully_bruised'])
	
	bruised_level += 1
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_SHOOT_BANAN_USE')
	
	animation.tween_callback(object, callback)
