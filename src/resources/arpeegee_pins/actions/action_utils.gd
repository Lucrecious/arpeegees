class_name ActionUtils

static func get_closest_adjecent_position(actioner: Node2D, target: Node2D) -> Vector2:
	var actioner_bounding_box := NodE.get_child(actioner, REferenceRect) as REferenceRect
	var target_bounding_box := NodE.get_child(target, REferenceRect) as REferenceRect
	
	var actioner_rect := actioner_bounding_box.global_rect()
	var target_rect := target_bounding_box.global_rect()
	
	var away_direction := sign(actioner_rect.get_center().x - target_rect.get_center().x)
	
	var position := target_rect.get_center()
	position += Vector2.DOWN * (target_rect.size.y / 2.0)
	position += away_direction * Vector2.RIGHT * (target_rect.size.x / 2.0)
	position += away_direction * Vector2.RIGHT * (actioner_rect.size.x / 2.0)
	position += Vector2.UP * (actioner_rect.size.y / 2.0)
	position += Vector2.DOWN * .01
	
	return position - actioner_rect.get_center()

static func get_head_position(target: Node2D) -> Vector2:
	var bounding_box := NodE.get_child(target, REferenceRect) as REferenceRect
	var rect := bounding_box.global_rect()
	return rect.get_center() + Vector2.UP * (rect.size.y / 4.0)

static func get_top_right_corner_screen(pin: Node2D) -> Vector2:
	var bounding_box := NodE.get_child(pin, REferenceRect) as REferenceRect
	var global_rect := bounding_box.global_rect()
	var position := global_rect.position + Vector2.RIGHT * global_rect.size
	return position

static func add_attack(tween:SceneTreeTween, actioner: ArpeegeePinNode, target: ArpeegeePinNode,
		amount: int) -> void:
	_add_attack(tween, actioner, target, amount, PinAction.AttackType.Normal, false)

static func add_attack_no_evade(tween: SceneTreeTween, actioner: ArpeegeePinNode, target: ArpeegeePinNode,
		amount: int) -> void:
	_add_attack(tween, actioner, target, amount, PinAction.AttackType.Normal, true)

static func add_magic_attack(tween: SceneTreeTween, actioner:ArpeegeePinNode, target: ArpeegeePinNode,
		amount: int) -> void:
	_add_attack(tween, actioner, target, amount, PinAction.AttackType.Magic, false)

static func add_real_damage(tween: SceneTreeTween, target: ArpeegeePinNode, amount: int) -> void:
	var damage_receiver := NodE.get_child(target, DamageReceiver) as DamageReceiver
	tween.tween_callback(damage_receiver, 'real_damage', [amount])

static func add_miss(tween: SceneTreeTween, target: ArpeegeePinNode) -> void:
	var damage_receiver := NodE.get_child(target, DamageReceiver) as DamageReceiver
	tween.tween_callback(damage_receiver, 'evade')

static func _add_attack(tween: SceneTreeTween, actioner: ArpeegeePinNode, target: ArpeegeePinNode,
		amount: int, type: int, no_evade: bool) -> void:
	
	var target_evasion := (NodE.get_child(target, ModifiedPinStats) as ModifiedPinStats).evasion
	var damage_receiver := NodE.get_child(target, DamageReceiver) as DamageReceiver
	var is_miss := not no_evade
	if is_miss:
		is_miss = FairRandom.is_evading(target_evasion)
	
	if is_miss:
		tween.tween_callback(damage_receiver, 'evade')
	else:
		var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
		var is_critical := FairRandom.is_critical(modified_stats.critical)
		tween.tween_callback(damage_receiver, 'damage', [amount, type, is_critical])

static func add_hurt(tween: SceneTreeTween, target: ArpeegeePinNode) -> void:
	var damage_receiver := NodE.get_child(target, DamageReceiver) as DamageReceiver
	if not damage_receiver:
		return
	
	tween.tween_callback(damage_receiver, 'hurt')

static func add_projectile_shot(tween: SceneTreeTween,
		start_position: Vector2, target: ArpeegeePinNode,
		travel_sec: float, projectile_scene: PackedScene) -> Vector2:
	
	var projectile := projectile_scene.instance() as Node2D
	
	var end_position := get_head_position(target)
	
	tween.tween_callback(target.get_viewport(), 'add_child', [projectile])
	tween.tween_callback(projectile, 'set', ['position', start_position])
	tween.tween_property(projectile, 'position', end_position, travel_sec)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(projectile, 'queue_free')
	
	return end_position

# do at least 1 damage if factor is not 0
static func damage_with_factor(amount: int, factor: float) -> int:
	if is_equal_approx(factor, 0.0):
		return 0
	
	return int(max(floor(float(amount) * factor), 1))

static func add_jump(
		tween: SceneTreeTween, pin: ArpeegeePinNode,
		height: float, peak_sec: float, land_offset := 0.0) -> void:
	tween.tween_property(pin, 'global_position:y', pin.position.y - height, peak_sec)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(pin, 'global_position:y', pin.position.y - land_offset, peak_sec)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

static func add_walk(tween: SceneTreeTween, pin: ArpeegeePinNode, start_position: Vector2,
		target_position: Vector2, step_height: float, steps: int) -> Vector2:
	var relative := target_position - start_position
	
	var step_vector := relative / steps
	
	var step_sec := .1
	
	for i in steps:
		var end_location := start_position + (step_vector * (i + 1)) as Vector2
		var mid_location := start_position + (((step_vector * (float(i) + .5))) + (Vector2.UP *  step_height)) as Vector2
		
		tween.tween_property(pin, 'global_position', mid_location, step_sec / 2.0)
		tween.tween_property(pin, 'global_position', end_location, step_sec / 2.0)
		tween.tween_callback(Sounds, 'play_new_random', ['FootstepGrass', 3])
	
	return target_position

static func add_wind_up(tween: SceneTreeTween, pin: ArpeegeePinNode,
		position: Vector2, side: int) -> Vector2:
	side = int(sign(side))
	
	var target_position := position + Vector2.RIGHT * 50.0 * side
	tween.tween_property(pin, 'global_position', target_position, .35)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_interval(.3)
	
	return target_position

static func add_stab(tween: SceneTreeTween, pin: ArpeegeePinNode, target_position: Vector2) -> Vector2:
	tween.tween_property(pin, 'global_position', target_position, .2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	
	return target_position

static func add_shake(tween: SceneTreeTween, pin: ArpeegeePinNode, position: Vector2,
		axis: Vector2, magnitude: float, sec: float) -> void:
	
	tween.tween_method(_1, '_shake', 0.0, 1.0, sec, [pin, position, axis.normalized(), magnitude])
	tween.tween_property(pin, 'global_position', position, .05)

static func add_text_trigger(tween: SceneTreeTween, object: Object, translation: String) -> void:
	if not object.has_signal('text_triggered'):
		assert(false)
		return
	
	tween.tween_callback(object, 'emit_signal', ['text_triggered', translation])

static func add_shader_param_interpolation(tween: SceneTreeTween,
		material: ShaderMaterial, param: String,
		begin: float, end: float, duration: float) -> MethodTweener:
	return tween.tween_method(_1, '_set_shader_param', begin, end, duration, [material, param])

class _1:
	# todo: make this work wtith noise
	const noise := preload('res://src/resources/arpeegee_pins/actions/shake_noise.tres')
	static func _shake(_1: float, pin: ArpeegeePinNode, position: Vector2,
			axis: Vector2, magnitude: float) -> void:
		
		var s := sign(rand_range(-1.0, 1.0))
		pin.global_position = position + s * rand_range(0.7, 1.0) * axis * magnitude
	
	static func _set_shader_param(value: float, shader: ShaderMaterial, param: String) -> void:
		shader.set_shader_param(param, value)
