class_name JuiceSteppers

class SkewBackAndForth extends Reference:
	var offset := 0.0
	var offset_to_home_sec := 0.1
	var between_offsets_sec := 0.25
	var squish_top := 1.05
	var squish_bottom := 0.8
	var squish_end:= 1.0
	
	var _started := false
	var _finished := false
	var _current_sign := 1
	var _animation: SceneTreeTween
	var _material: ShaderMaterial
	func _init(animation: SceneTreeTween, material: ShaderMaterial) -> void:
		_animation = animation
		_material = material
	
	func step() -> void:
		if _finished:
			return
		
		if not _started:
			if not is_equal_approx(offset_to_home_sec, 0.0):
				_start()
			_started = true
			return
		
		TweenJuice.skew(_animation, _material,
				_current_sign * offset, 0.0, between_offsets_sec / 2.0).set_ease(Tween.EASE_IN)
		TweenJuice.squish(_animation.parallel(), _material,
				squish_top, squish_bottom, between_offsets_sec / 2.0).set_ease(Tween.EASE_IN)
		
		TweenJuice.skew(_animation, _material,
				0.0, -_current_sign * offset, between_offsets_sec / 2.0).set_ease(Tween.EASE_OUT)
		TweenJuice.squish(_animation.parallel(), _material,
				squish_bottom, squish_top, between_offsets_sec / 2.0).set_ease(Tween.EASE_OUT)
		
		_current_sign *= -1
	
	func finish() -> void:
		if not _started:
			return
		
		if _finished:
			return
		
		_finished = true
		TweenJuice.skew(_animation, _material, _current_sign * offset, 0.0, offset_to_home_sec)
		TweenJuice.squish(_animation.parallel(), _material, squish_top, squish_end, offset_to_home_sec)
	
	func _start() -> void:
		TweenJuice.skew(_animation, _material, 0.0, _current_sign * offset, offset_to_home_sec)
		TweenJuice.squish(_animation.parallel(), _material, squish_bottom, squish_top, offset_to_home_sec)
		
		
