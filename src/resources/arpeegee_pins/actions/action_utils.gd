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
	
	return position - actioner_rect.get_center()

static func get_top_right_corner_screen(pin: Node2D) -> Vector2:
	var bounding_box := NodE.get_child(pin, REferenceRect) as REferenceRect
	var global_rect := bounding_box.global_rect()
	var position := global_rect.position + Vector2.RIGHT * global_rect.size
	return position

static func add_damage(tween: SceneTreeTween, target: ArpeegeePinNode, amount: int) -> void:
	var damage_receiver := NodE.get_child(target, DamageReceiver) as DamageReceiver
	if not damage_receiver:
		return
	
	tween.tween_callback(damage_receiver, 'damage', [amount])

static func add_status_effect(tween: SceneTreeTween, target: ArpeegeePinNode, effect: String) -> void:
	var status_effects := NodE.get_child(target, StatusEffectsList) as StatusEffectsList
	if not status_effects:
		return
	
	tween.tween_callback(status_effects, 'add', [effect])
