extends Node

const ImpactWhiteScene := preload('res://src/vfx/impact_white.tscn')
const FloatingNumberScene := preload('res://src/vfx/floating_number.tscn')

func physical_impact(node: Node2D, position_node: Node2D) -> void:
	var impact_white := ImpactWhiteScene.instance() as AnimatedSprite
	node.get_viewport().add_child(impact_white)
	impact_white.global_position = position_node.global_position
	
	impact_white.connect('animation_finished', impact_white, 'queue_free', [],
			CONNECT_ONESHOT | CONNECT_DEFERRED)
	impact_white.play('default')

func floating_number(pin: ArpeegeePinNode, value: int, parent: Node) -> void:
	assert(pin)
	assert(parent)
	
	var bounding_box := NodE.get_child(pin, REferenceRect) as REferenceRect
	assert(bounding_box)
	
	var floating_number := FloatingNumberScene.instance() as FloatingNumber
	floating_number.value = value
	
	parent.add_child(floating_number)
	
	var rect := bounding_box.global_rect()
	
	var number_start_position := rect.get_center() + Vector2.UP * rect.size.y / 4.0
	floating_number.global_position = number_start_position
	var distance_to_top := -(rect.position.y - number_start_position.y)
	floating_number.float_up(distance_to_top * 2.0)
