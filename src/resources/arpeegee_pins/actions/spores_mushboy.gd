extends Node2D

signal text_triggered(narration_key)

enum Type {
	Poison,
	Sleepy,
	Smelly,
}

export(Type) var type := Type.Poison
export(Color) var spore_color := Color.white
export(String) var narration_key := ''

onready var _spore_shooter := NodE.get_sibling_by_name(self, 'Spores') as CPUParticles2D

func pin_action() -> PinAction:
	if type == Type.Poison:
		return preload('res://src/resources/actions/poison_spores_mushboy.tres')
	elif type == Type.Sleepy:
		return preload('res://src/resources/actions/sleepy_spores_mushboy.tres')
	elif type == Type.Smelly:
		return preload('res://src/resources/actions/smelly_spores_mushboy.tres')
	else:
		assert(false)
		return preload('res://src/resources/actions/poison_spores_mushboy.tres')

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	var  sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['sporessetup'])
	
	animation.tween_interval(0.75)
	animation.tween_callback(sprite_switcher, 'change', ['sporespush'])
	
	var target_box := NodE.get_child(target, REferenceRect) as REferenceRect
	var target_position := target_box.global_rect().get_center()
	var direction := target_position - actioner.global_position
	
	_spore_shooter.color = spore_color
	_spore_shooter.direction = direction
	animation.tween_callback(_spore_shooter, 'set', ['emitting', true])
	animation.tween_interval(0.75)
	animation.tween_callback(_spore_shooter, 'set', ['emitting', false])
	
	var list := NodE.get_child(target, StatusEffectsList) as StatusEffectsList
	animation.tween_callback(list, 'add_instance', [_create_status_effect(target)])
	
	assert(not narration_key.empty())
	
	ActionUtils.add_text_trigger(animation, self, narration_key)
	
	animation.tween_callback(sprite_switcher, 'change', ['sporessetup'])
	animation.tween_interval(1.0)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)

func _create_status_effect(target: Node2D) -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 1
	status_effect.is_ailment = true
	
	if type == Type.Poison:
		status_effect.tag = StatusEffectTag.Poison
	elif type == Type.Sleepy:
		status_effect.tag = StatusEffectTag.Sleep
	elif type == Type.Smelly:
		status_effect.tag = StatusEffectTag.Smelly
	else:
		assert(false)
		status_effect.tag = StatusEffectTag.Poision
	
	var effect: Node
	var auras := Aura.create_spore_auras(spore_color)
	if type == Type.Poison:
		effect = EffectFunctions.Poison.new(target)
	elif type == Type.Sleepy:
		effect = EffectFunctions.Sleep.new(target)
	elif type == Type.Smelly:
		effect = null 

	assert(effect)
	
	status_effect.add_child(effect)
	NodE.add_children(status_effect, auras)
	
	return status_effect

