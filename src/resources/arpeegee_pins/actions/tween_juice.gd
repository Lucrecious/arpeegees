class_name TweenJuice

static func skew(animation: SceneTreeTween, material: ShaderMaterial,
		start: float, end: float, sec: float) -> MethodTweener:
	return ActionUtils.add_shader_param_interpolation(animation,
			material, 'top_skew', start, end, sec)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)

static func squish(animation: SceneTreeTween, material: ShaderMaterial,
		start: float, end: float, sec: float) -> MethodTweener:
	return ActionUtils.add_shader_param_interpolation(animation,
			material, 'squash', start, end, sec)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
