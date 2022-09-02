extends Node

const ExplosionTemplateScene := preload('res://src/vfx/explosion.tscn')
const ImpactWhiteScene := preload('res://src/vfx/impact_white.tscn')
const FloatingNumberScene := preload('res://src/vfx/floating_number.tscn')

func note_explosion(front: bool) -> CPUParticles2D:
	var explosion := ExplosionTemplateScene.instance() as ExplosionParticles
	if randi() % 2 == 0:
		explosion.texture = load('res://assets/sprites/effects/note1_vfx.png')
	else:
		explosion.texture = load('res://assets/sprites/effects/note2_vfx.png')
	
	explosion.scale_amount = 1.0
	explosion.spread = 50.0
	if front:
		explosion.z_index = Aura.Z_INDEX_FRONT
	
	return explosion

func power_up_initial_explosion() -> Array:
	var front := ExplosionTemplateScene.instance() as ExplosionParticles
	front.texture = load('res://assets/sprites/effects/hero_smoke%d.png' % [RaNdom.randi_range(1, 7)])
	front.scale_amount = 0.4
	front.amount = 5
	front.spread = 35
	front.z_index = Aura.Z_INDEX_FRONT
	
	var back := ExplosionTemplateScene.instance() as ExplosionParticles
	back.texture = load('res://assets/sprites/effects/hero_smoke%d.png' % [RaNdom.randi_range(1, 7)])
	back.scale_amount = 0.4
	front.amount = 5
	back.spread = 35.0
	
	return [front, back]

func shield_vfx() -> Node2D:
	var shield_vfx := preload('res://src/vfx/shield_vfx.tscn').instance() as Node2D
	return shield_vfx

func physical_impact(node: Node2D, position_node: Node2D) -> void:
	physical_impactv(node, position_node.global_position)

func physical_impactv(node: Node2D, position: Vector2) -> void:
	var impact_white := ImpactWhiteScene.instance() as AnimatedSprite
	node.get_viewport().add_child(impact_white)
	impact_white.global_position = position
	
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
