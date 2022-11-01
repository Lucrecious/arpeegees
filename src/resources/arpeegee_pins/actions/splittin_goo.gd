class_name GooShotTrapAction
extends Node2D

signal text_triggered(translation)

enum Type {
	GooShot,
	GooTrap,
}

export(Type) var type := Type.GooShot

onready var _goo_shot := $GooShot as Node2D

func _ready() -> void:
	_goo_shot.visible = false

func pin_action() -> PinAction:
	if type == Type.GooShot:
		return preload('res://src/resources/actions/spittin_goo_blobbo.tres')
	elif type == Type.GooTrap:
		return preload('res://src/resources/actions/goo_trap_blobbo.tres')
	else:
		assert(false)
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
	
	var trap_succeeds := false
	var already_trapped := false
	
	if type == Type.GooShot:
		var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
		for t in targets:
			var attack_amount := ActionUtils.damage_with_factor(modified_stats.attack, 0.5)
			ActionUtils.add_attack(animation, actioner, t, attack_amount)
			var hit_position := NodE.get_child(t, REferenceRect).global_rect().get_center() as Vector2
			animation.tween_callback(VFX, 'physical_impactv', [t, hit_position])
	elif type == Type.GooTrap:
		if _trap_succeeds():
			trap_succeeds = true
			for t in targets:
				var status_effects_list := NodE.get_child(t, StatusEffectsList) as StatusEffectsList
				if status_effects_list.count_tags(StatusEffectTag.GooTrap):
					already_trapped = true
				else:
					var status_effect := _create_goo_trap_status_effect(t)
					animation.tween_callback(status_effects_list, 'add_instance', [status_effect])
	else:
		assert(false)
	
	TweenJuice.skew(animation, material, 0.5, 0.0, 0.5)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	if type == Type.GooShot:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_SPITTIN_GOO_USE')
	elif type == Type.GooTrap:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_GOO_TRAP_USE')
		if trap_succeeds:
			if already_trapped:
				ActionUtils.add_text_trigger(animation, self, 'NARRATOR_GOO_TRAP_ALREADY_GOOED')
			else:
				ActionUtils.add_text_trigger(animation, self, 'NARRATOR_GOO_TRAP_SUCCEED')
		else:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_GOO_TRAP_FAIL')
	else:
		assert(false)
	
	animation.tween_callback(object, callback)

func _create_goo_trap_status_effect(pin: ArpeegeePinNode) -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.GooTrap
	
	var goo_dripping := Aura.create_green_goo_aura(pin)
	NodE.add_children(status_effect, goo_dripping)
	
	var effect := GooTrapEffect.new()
	status_effect.add_child(effect)
	
	return status_effect

func _trap_succeeds() -> bool:
	return randf() < 0.3

class GooTrapEffect extends Node:
	signal text_triggered(translation_key)
	signal start_turn_effect_finished()

	const RUNS_ALIVE := 2

	var runs_alive := RUNS_ALIVE

	onready var _pin := NodE.get_ancestor(self, ArpeegeePinNode) as ArpeegeePinNode
	onready var _actions := NodE.get_child(_pin, PinActions) as PinActions
	
	func run_start_turn_effect() -> void:
		var tween := create_tween()
		tween.tween_interval(0.2)
		
		runs_alive -= 1
		
		tween.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
		
		if runs_alive < 0:
			tween.tween_callback(StatusEffect, 'queue_free_leave_particles_until_dead', [get_parent()])
		
		if runs_alive < 0:
			return
		
		_actions.set_moveless(true)

	func run_end_turn_effect() -> void:
		_actions.set_moveless(false)

