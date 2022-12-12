extends Node2D

signal text_triggered(narration_key)

var _is_blocked := false
func is_blocked() -> bool:
	return _is_blocked

func pin_action() -> PinAction:
	return load('res://src/resources/actions/surrounded_by_slices_banan_chopped.tres') as PinAction

func run(actioner: Node2D, object: Object, callback: String) -> void:
	_is_blocked = true
	
	var damage_receiver := NodE.get_child(actioner, DamageReceiver) as DamageReceiver
	damage_receiver.connect('hit', self, '_on_hit', [actioner])
	
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	var root_sprite := Components.root_sprite(actioner)
	
	var sounds := NodE.get_child(actioner, SoundsComponent)
	animation.tween_callback(sounds, 'play', ['SurroundedBySlices'])
	
	for i in 3:
		var slice := root_sprite.get_node('Slice%d' % [i + 1])
		if not slice.has_method('start'):
			continue
		
		slice.visible = true
		slice.self_modulate.a = 0.0
		slice.start()
		animation.tween_property(slice, 'self_modulate:a', 1.0, 1.0)
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_SURROUNDED_BY_SLICES_USE')
	
	animation.tween_callback(object, callback)

func _on_hit(hitter, actioner: ArpeegeePinNode) -> void:
	if not hitter:
		return
	
	var pin := hitter as ArpeegeePinNode
	if not pin:
		assert(false)
		return
	
	if pin.resource.type != ArpeegeePin.Type.Player:
		return
	
	var stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var  damage_amount := ActionUtils.damage_with_factor(stats.attack, 0.3)
	var damage_receiver := NodE.get_child(pin, DamageReceiver) as DamageReceiver
	
	var animation := create_tween()
	animation.tween_interval(0.5)
	animation.tween_callback(damage_receiver, 'damage', [damage_amount, PinAction.AttackType.Normal, false, actioner])
	
	animation.tween_callback(Sounds, 'play', ['DamageLight'])
	
	Logger.info('calling text trigger for "NARRATOR_SURROUNDED_BY_SLICES_DAMAGE" during actioner damage receiver')
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_SURROUNDED_BY_SLICES_DAMAGE')
