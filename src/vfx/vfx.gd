extends Node

const ImpactWhite := preload('res://src/vfx/impact_white.tscn')

func physical_impact(node: Node2D, position_node: Node2D) -> void:
	var impact_white := ImpactWhite.instance() as AnimatedSprite
	node.get_viewport().add_child(impact_white)
	impact_white.global_position = position_node.global_position
	
	impact_white.connect('animation_finished', impact_white, 'queue_free', [],
			CONNECT_ONESHOT | CONNECT_DEFERRED)
	impact_white.play('default')
