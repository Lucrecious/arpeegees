extends Node2D

signal text_triggered(narration_key)

const MIN_HITS := 2
const MAX_HITS := 5

enum Type {
	Sparkling,
	Sword
}

export(Type) var type := Type.Sparkling

onready var _goo := $Goo as Node2D

func pin_action() -> PinAction:
	if type == Type.Sparkling:
		return preload('res://src/resources/actions/spittin_goo_blobbo_sparkling.tres') as PinAction
	elif type == Type.Sword:
		return preload('res://src/resources/actions/spittin_goo_blobbo_sword.tres') as PinAction
	else:
		assert(false)
		return preload('res://src/resources/actions/spittin_goo_blobbo_sparkling.tres')

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	var root_sprite := Components.root_sprite(actioner)
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var material := root_sprite.material as ShaderMaterial
	var target_box := NodE.get_child(target, REferenceRect) as REferenceRect
	var target_position := target_box.global_rect().get_center()
	var attack_times := MIN_HITS + randi() % (MAX_HITS - MIN_HITS)
	var stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var damage := ActionUtils.damage_with_factor(stats.attack, 0.3)
	var sounds := NodE.get_child(actioner, SoundsComponent)
	for i in attack_times:
		animation.tween_callback(Sounds, 'play', ['WindUpAttack'])
		TweenJuice.skew(animation, material, 0.0, -0.3, 0.5)\
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
				
		animation.tween_callback(Sounds, 'play', ['Dash1'])
		TweenJuice.skew(animation, material, -0.3, 0.0, 0.1)
		
		if type == Type.Sparkling:
			animation.tween_callback(sprite_switcher, 'change', ['shootgoo'])
		
		animation.tween_callback(_goo, 'set', ['visible', true])
		animation.tween_property(_goo, 'global_position', target_position, 0.1)
		
		ActionUtils.add_attack(animation, actioner, target, damage)
		animation.tween_callback(VFX, 'physical_impactv', [target, target_position])
		
		if type == Type.Sword:
			animation.tween_callback(sounds, 'play', ['GooShot'])
		elif type == Type.Sparkling:
			animation.tween_callback(sounds, 'play', ['SpittinGoo'])
		
		animation.tween_interval(0.25)
		animation.tween_callback(sprite_switcher, 'change', ['idle'])
		
		animation.tween_callback(_goo, 'set', ['visible', false])
		animation.tween_callback(_goo, 'set', ['global_position', _goo.global_position])
		
		animation.tween_interval(0.35)
	
			
	if type == Type.Sparkling:
		ActionUtils.add_text_trigger_ordered(animation, self, 'NARRATOR_SPITTIN_GOO_PURPLE_', 7, 1)
	elif type == Type.Sword:
		ActionUtils.add_text_trigger_limited(animation, self, 'NARRATOR_SPLITTIN_GOO_USE_SWORD_IN_BLOBBO')
	
	animation.tween_interval(0.5)
	animation.tween_callback(object, callback)
