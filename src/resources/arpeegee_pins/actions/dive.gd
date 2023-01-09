extends Node2D

signal text_triggered(translation_key)

func pin_action() -> PinAction:
	return load('res://src/resources/actions/harpy_dive.tres') as PinAction

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var relative := ActionUtils.get_closest_adjecent_position(actioner, target)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var sounds := NodE.get_child(actioner, SoundsComponent) as SoundsComponent
	
	var divehead_sprite := sprite_switcher.sprite('divehead')
	assert(divehead_sprite)
	
	var squisher := NodE.get_child(actioner, Squisher) as Squisher
	
	var tween := get_tree().create_tween()
	
	tween.tween_callback(sounds, 'play', ['Squish'])
	
	tween.tween_property(squisher, 'height_factor', .3, .5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.parallel().tween_property(squisher, 'squish_factor', .5, .5)
	tween.tween_interval(.5)
	tween.tween_callback(sounds, 'play', ['Ascend'])
	tween.tween_callback(sprite_switcher, 'change', ['diveup'])
	tween.tween_property(squisher, 'height_factor', 1.7, .2)
	
	tween.tween_property(actioner, 'global_position', actioner.global_position + Vector2.UP * 1000.0, .3)
	
	tween.tween_callback(squisher, 'set', ['height_factor', 1.0])
	tween.tween_callback(squisher, 'set', ['squish_factor', 1.0])
	tween.tween_callback(sprite_switcher, 'change', ['divehead'])
	tween.tween_interval(.7)
	
	tween.tween_callback(sounds, 'play', ['DiveBombCry'])
	tween.tween_property(actioner, 'global_position', actioner.global_position + relative, .2)
	
	tween.tween_callback(sounds, 'play', ['DiveBombHit'])
	
	ActionUtils.add_text_trigger_ordered(tween, self, 'NARRATOR_DIVE_BOMB_USE_', 4, 1)
	
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	if modified_stats:
		ActionUtils.add_attack(tween, actioner, target,
				ActionUtils.damage_with_factor(modified_stats.attack, 1.0))
	else:
		assert(false)
	
	var impact_position := NodE.get_child(target, REferenceRect).global_rect().get_center() as Vector2
	tween.tween_callback(VFX, 'physical_impactv', [target, impact_position])
	
	tween.tween_interval(.5)
	tween.tween_callback(sprite_switcher, 'change', ['idle'])
	tween.tween_property(actioner, 'global_position', actioner.global_position, .3)
	
	tween.tween_callback(object, callback)
