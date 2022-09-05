extends Node2D

onready var _wind_up_sfx := $WindUp as AudioStreamPlayer
onready var _jump_sfx := $Jump as AudioStreamPlayer
onready var _impact_sfx := $Impact as AudioStreamPlayer

func pin_action() -> PinAction:
	return load('res://src/resources/actions/harpy_dive.tres') as PinAction

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var relative := ActionUtils.get_closest_adjecent_position(actioner, target)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var divehead_sprite := sprite_switcher.sprite('divehead')
	assert(divehead_sprite)
	
	var squisher := NodE.get_child(actioner, Squisher) as Squisher
	
	var tween := get_tree().create_tween()
	
	tween.tween_callback(_wind_up_sfx, 'play')
	
	tween.tween_property(squisher, 'height_factor', .3, .5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.parallel().tween_property(squisher, 'squish_factor', .5, .5)
	tween.tween_interval(.5)
	tween.tween_callback(_jump_sfx, 'play')
	tween.tween_callback(sprite_switcher, 'change', ['divehead'])
	tween.tween_callback(divehead_sprite, 'set', ['rotation_degrees', -129.0])
	tween.tween_property(squisher, 'height_factor', 1.7, .2)
	
	tween.tween_property(actioner, 'global_position', actioner.global_position + Vector2.UP * 1000.0, .3)
	
	tween.tween_callback(squisher, 'set', ['height_factor', 1.0])
	tween.tween_callback(squisher, 'set', ['squish_factor', 1.0])
	tween.tween_callback(divehead_sprite, 'set', ['rotation_degrees', 0.0])
	tween.tween_interval(.7)
	tween.tween_property(actioner, 'global_position', actioner.global_position + relative, .2)
	
	tween.tween_callback(_impact_sfx, 'play')
	
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	if modified_stats:
		ActionUtils.add_attack(tween, actioner, target, modified_stats.attack)
	else:
		assert(false)
	
	tween.tween_interval(.5)
	tween.tween_callback(sprite_switcher, 'change', ['idle'])
	tween.tween_property(actioner, 'global_position', actioner.global_position, .3)
	tween.tween_callback(object, callback)
