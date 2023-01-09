extends Node2D

signal text_triggered(narration_key)

enum Type {
	Splish,
	Puddle,
}

export(Type) var type := Type.Splish

# splish
const ATTACK_INCREASE := 0.1
const MAX_ATTACK_FACTOR := 3.5

var attack_factor := 1.0

onready var _particles := $Particles as CPUParticles2D

var _is_blocked := false
func is_blocked() -> bool:
	return _is_blocked

func pin_action() -> PinAction:
	if type == Type.Splish:
		return preload('res://src/resources/actions/splish_shifty_fishguy.tres')
	elif type == Type.Puddle:
		return preload('res://src/resources/actions/puddle_shifty_fishguy.tres')
	
	assert(false)
	return null

var _uses := 0
func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	if type == Type.Puddle:
		_is_blocked = true
	
	var animation := create_tween()
	
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['throw'])
	
	var sounds := NodE.get_child(actioner, SoundsComponent)
	if type == Type.Splish:
		animation.tween_callback(sounds, 'play', ['Splish'])
	elif type == Type.Puddle:
		animation.tween_callback(sounds, 'play', ['SplishWindUp'])
	
	animation.tween_callback(_particles, 'set', ['emitting', true])
	
	if type == Type.Puddle:
		var puddle_animation_player_group := get_tree().get_nodes_in_group('puddle_animation_player')
		if puddle_animation_player_group.empty():
			assert(false)
		else:
			var puddle_animation_player := puddle_animation_player_group[0] as AnimationPlayer
			animation.tween_callback(puddle_animation_player, 'play', ['add_puddle'])
	
	animation.tween_interval(1.0)
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var attack_amount := ActionUtils.damage_with_factor(
			modified_stats.magic_attack, attack_factor)
	
	if type == Type.Splish:
		for t in targets:
			ActionUtils.add_attack(animation, actioner, t, attack_amount)
	elif type == Type.Puddle:
		SlipEffect.add_slip_effect(animation, targets)
	
	if type == Type.Splish:
		if _uses < 1:
			ActionUtils.add_text_trigger_limited(animation, self, 'NARRATOR_SPLISH_USE_1')
		else:
			ActionUtils.add_text_trigger_limited(animation, self, 'NARRATOR_SPLISH_USE_2')
	elif type == Type.Puddle:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_PUDDLE_USE')
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	var next_attack_factor := min(attack_factor + ATTACK_INCREASE, MAX_ATTACK_FACTOR)
	animation.tween_callback(self, 'set', ['attack_factor', next_attack_factor])
	animation.tween_callback(object, callback)
	
	_uses += 1
