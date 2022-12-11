extends Node2D

signal text_triggered(translation_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/angelic_heal_harpy.tres')

func run(actioner: Node2D, object: Object, callback: String) -> void:
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var sounds := NodE.get_child(actioner, SoundsComponent) as SoundsComponent
	
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	
	animation.tween_callback(sprite_switcher, 'change', ['winggust'])
	animation.tween_callback(sounds, 'play', ['Heal'])
	
	var heart_explosion := VFX.heart_explosion()
	animation.tween_callback(NodE, 'add_children', [self, heart_explosion])
	
	var health := NodE.get_child(actioner, Health) as Health
	var stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	animation.tween_callback(health, 'current_set', [min(health.current + 5, stats.max_health)])
	
	animation.tween_interval(0.75)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_ANGELIC_HEAL_USE')
	
	animation.tween_callback(object, callback)
