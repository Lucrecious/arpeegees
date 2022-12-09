extends Node2D

signal text_triggered(narration_key)

var _boosted := false
func boost_from_combing() -> void:
	_boosted = true

func block() -> void:
	_is_blocked = true

var _is_blocked := false
func is_blocked() -> bool:
	return _is_blocked

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/bright_sparkles_paladin.tres')

func run(actioner: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['magicsparkles'])
	
	animation.tween_callback(VFX, 'bright_sparkles', [actioner])
	
	var sounds := NodE.get_child(actioner, SoundsComponent)
	animation.tween_callback(sounds, 'play', ['BrightSparkles'])
	
	animation.tween_callback(EffectFunctions, 'bright_sparkles', [actioner, _boosted])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_BRIGHT_SPARKLES_USE')
	
	animation.tween_interval(0.75)
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	var enamored := get_tree().get_nodes_in_group('harpy_enamored')
	for e in enamored:
		if e.is_enamored():
			continue
		animation.tween_callback(e, 'enamore')
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_HARPY_LOVES_SPARKLES')
	
	var blobbo_kisses := get_tree().get_nodes_in_group('blobbo_kiss')
	for b in blobbo_kisses:
		b.add_sparkles_kiss(animation, self, actioner)
	
	animation.tween_callback(object, callback)
