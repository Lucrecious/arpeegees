extends Node2D

signal text_triggered(narration_key)

enum Type {
	BiteKoboldio,
	SloppySlapDeflatedMushboy,
}

export(Type) var type := Type.BiteKoboldio
export(String) var attack_frame := ''
export(String) var narration_key := ''

const MIN_ATTACKS := 2
const MAX_ATTACKS := 5

func pin_action() -> PinAction:
	if type == Type.BiteKoboldio:
		return preload('res://src/resources/actions/bite_koboldio.tres')
	elif type == Type.SloppySlapDeflatedMushboy:
		return preload('res://src/resources/actions/sloppy_slap_mushboy_deflated.tres')
	else:
		assert(false)
		return preload('res://src/resources/actions/bite_koboldio.tres')

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	var target_position := ActionUtils.get_closest_adjecent_position(actioner, target) + actioner.global_position
	ActionUtils.add_walk(animation, actioner, actioner.global_position, target_position, 15.0, 5)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var damage := 1
	if type == Type.BiteKoboldio:
		damage = ActionUtils.damage_with_factor(stats.attack, 0.3)
	elif type == Type.SloppySlapDeflatedMushboy:
		damage = ActionUtils.damage_with_factor(stats.attack, 1.0)
	
	var impact_position := NodE.get_child(target, REferenceRect).global_rect().get_center() as Vector2
	var attack_times := MIN_ATTACKS + randi() % (MAX_ATTACKS - MIN_ATTACKS)
	for i in attack_times:
		ActionUtils.add_wind_up(animation, actioner, target_position, -1)
		ActionUtils.add_stab(animation, actioner, target_position)
		
		animation.tween_callback(sprite_switcher, 'change', [attack_frame])
		ActionUtils.add_attack(animation, actioner, target, damage)
		
		animation.tween_callback(VFX, 'physical_impactv', [target, impact_position])
		
		ActionUtils.add_shake(animation, actioner, target_position, Vector2.RIGHT, 10, 0.25)
		
		animation.tween_interval(0.5)
		
		animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	
	animation.tween_interval(0.5)
	
	if not narration_key.empty():
		ActionUtils.add_text_trigger(animation, self, narration_key)
	
	ActionUtils.add_walk(animation, actioner, target_position, actioner.global_position, 15.0, 5)
	
	animation.tween_callback(object, callback)
