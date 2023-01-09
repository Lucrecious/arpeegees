extends Node2D

signal text_triggered(narration_key)

const MIN_HITS := 2
const MAX_HITS := 7

func pin_action() -> PinAction:
	return load('res://src/resources/actions/slice_barrage_banan_chopped.tres') as PinAction

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	animation.tween_interval(0.5)
	
	var target_box := NodE.get_child(target, REferenceRect) as REferenceRect
	var target_center := target_box.global_rect().get_center()
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var slices_node := sprite_switcher.sprite('idle')
	
	var stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var damage_amount := ActionUtils.damage_with_factor(stats.attack, 0.3)
	var attack_times := MIN_HITS + (randi() % (MAX_HITS - MIN_HITS))
	var slice_order := slices_node.get_children()
	
	var sounds := NodE.get_child(actioner, SoundsComponent)
	
	for i in attack_times:
		var slice := slice_order[i] as Node2D
		
		animation.tween_callback(sounds, 'play', ['SliceBarrage'])
		
		animation.tween_property(slice, 'global_position', target_center, 0.75)\
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		ActionUtils.add_attack(animation, actioner, target, damage_amount)
		
		animation.tween_callback(Sounds, 'play', ['DamageLight'])
		
		animation.tween_callback(VFX, 'physical_impactv', [target, target_center])
		
		animation.tween_callback(slice, 'set', ['visible', false])
		
		animation.tween_interval(0.35)
	
	ActionUtils.add_text_trigger_limited(animation, self, 'NARRATOR_SLICE_BARRAGE_USE')
	
	animation.tween_interval(1.0)
	
	for i in attack_times:
		var slice := slice_order[i] as Node2D
		animation.tween_callback(slice, 'set', ['global_position', slice.global_position])
		animation.tween_callback(slice, 'set', ['visible', true])
	
	animation.tween_callback(object, callback)
