extends Node2D

signal text_triggered(translation)

onready var _goo_shot := $GooShot as Node2D

func _ready() -> void:
	_goo_shot.visible = false

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/spittin_goo_blobbo.tres')

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var root_sprite := Components.root_sprite(actioner)
	var material := root_sprite.material as ShaderMaterial
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var actioner_box := NodE.get_child(actioner, REferenceRect) as REferenceRect
	
	if targets.empty():
		assert(false)
		object.call(callback)
		return
	
	_goo_shot.visible = false
	_goo_shot.global_position = actioner_box.global_position
	
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	
	TweenJuice.skew(animation, material, 0.0, -0.5, 1.0)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	animation.tween_interval(0.5)
	
	TweenJuice.skew(animation, material, -0.5, 0.5, 0.1)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	
	animation.tween_callback(sprite_switcher, 'change', ['attack'])
	
	animation.tween_callback(_goo_shot, 'set_deferred', ['visible', true])
	
	var target_position := Vector2.ZERO
	for p in targets:
		var box := NodE.get_child(p, REferenceRect) as REferenceRect
		target_position += box.global_rect().get_center()
	target_position /= targets.size()
	
	animation.tween_property(_goo_shot, 'global_position', target_position, 0.25)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	var explosions := VFX.goo_explosions()
	animation.tween_callback(NodE, 'add_children', [actioner.get_parent(), explosions])
	for e in explosions:
		animation.parallel().tween_callback(e, 'set_deferred', ['global_position', target_position])
	
	animation.tween_callback(_goo_shot, 'set_deferred', ['visible', false])
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	for t in targets:
		var attack_amount := ActionUtils.damage_with_factor(modified_stats.attack, 0.5)
		ActionUtils.add_attack(animation, actioner, t, attack_amount)
	
	TweenJuice.skew(animation, material, 0.5, 0.0, 0.5)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	animation.tween_callback(object, callback)
