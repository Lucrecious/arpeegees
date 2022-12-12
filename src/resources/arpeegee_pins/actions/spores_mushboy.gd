extends Node2D

signal text_triggered(narration_key)

enum Type {
	Poison,
	Sleepy,
	Smelly,
}

export(Type) var type := Type.Poison
export(String) var narration_key := ''
export(Texture) var spore_texture: Texture = null
export(float) var scale_amount := 1.0

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
	
	_spore_shooter.texture = spore_texture
	_spore_shooter.scale_amount = scale_amount
	_spore_shooter.direction = direction
	if type == Type.Smelly:
		_spore_shooter.angle = 90.0
	else:
		_spore_shooter.angle = 0.0
	
	var sounds := NodE.get_child(actioner, SoundsComponent)
	animation.tween_callback(sounds, 'play', ['Spore'])
	
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
		status_effect.tag = StatusEffectTag.Poison
	
	var auras := Aura.create_spore_auras(spore_texture, scale_amount)
	if type == Type.Poison:
		var effect := EffectFunctions.Poison.new()
		
		status_effect.add_child(effect)
	
	elif type == Type.Sleepy:
		var effect := EffectFunctions.Sleep.new()
		
		status_effect.add_child(effect)
	
	elif type == Type.Smelly:
		var stats := NodE.get_child(target, ModifiedPinStats) as ModifiedPinStats
		var modifiers := []
		if stats.attack > 1:
			var attack_down := StatModifier.new()
			attack_down.type = StatModifier.Type.Attack
			attack_down.add_amount = -1
			
			modifiers.push_back(attack_down)
		
		if stats.magic_attack > 1:
			var magic_attack_down := StatModifier.new()
			magic_attack_down.type = StatModifier.Type.MagicAttack
			magic_attack_down.add_amount = -1
			
			modifiers.push_back(magic_attack_down)
		
		NodE.add_children(status_effect, modifiers)
	
	NodE.add_children(status_effect, auras)
	
	return status_effect

