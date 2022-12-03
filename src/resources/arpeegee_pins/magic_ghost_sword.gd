extends Node2D

func add_attack(animation: SceneTreeTween, pin: ArpeegeePinNode, targets: Array, attack_amount: int) -> void:
	for t in targets:
		var target_position := ActionUtils.get_closest_adjecent_position(pin, t) + pin.global_position
		
		animation.tween_property(self, 'global_position', target_position, 0.25)\
				.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		
		animation.tween_property(self, 'rotation_degrees', 15.0, 0.75)\
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		
		animation.tween_property(self, 'rotation_degrees', -80.0, 0.07)
		
		ActionUtils.add_magic_attack(animation, pin, t, attack_amount)
		
		animation.tween_interval(0.5)
		animation.tween_property(self, 'rotation_degrees', 0.0, 0.5)\
				.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	var rect_node := NodE.get_child(pin, REferenceRect)
	var normal_position := (rect_node.global_rect().position + rect_node.global_rect().size + Vector2.RIGHT * 25.0) as Vector2
	animation.tween_property(self, 'global_position', normal_position, 0.25)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
