extends Node

const ExplosionTemplateScene := preload('res://src/vfx/explosion.tscn')
const ImpactWhiteScene := preload('res://src/vfx/impact_white.tscn')
const FloatingTextScene := preload('res://src/vfx/floating_text.tscn')

func goo_explosions() -> Array:
	var explosion := ExplosionTemplateScene.instance() as ExplosionParticles
	explosion.texture = load('res://assets/sprites/effects/goo_glob.png')
	explosion.scale_amount = 0.2
	explosion.amount = 30
	explosion.spread = 180.0
	
	return [explosion]

func death_explosion() -> Array:
	var explosion := ExplosionTemplateScene.instance() as ExplosionParticles
	explosion.texture = load('res://assets/sprites/effects/death_smoke.png')
	explosion.spread = 15.0
	explosion.amount = 8
	explosion.damping = 0.1
	explosion.initial_velocity = 700.0
	explosion.initial_velocity_random = 0.5
	return [explosion]

func heart_explosion() -> Array:
	var explosion := ExplosionTemplateScene.instance() as ExplosionParticles
	explosion.texture = load('res://assets/sprites/effects/heart1.png')
	explosion.scale_amount = 1.0
	explosion.spread = 45.0
	
	return [explosion]

func sparkle_explosions() -> Array:
	var explosion := ExplosionTemplateScene.instance() as ExplosionParticles
	explosion.spread = 180.0
	explosion.scale_amount = 0.7
	explosion.texture = load('res://assets/sprites/effects/sparkle5.png')
	
	return [explosion]

func bright_sparkles(pin: ArpeegeePinNode) -> void:
	var box := NodE.get_child(pin, REferenceRect) as REferenceRect
	for i in range(5):
		var explosion := ExplosionTemplateScene.instance() as ExplosionParticles
		explosion.spread = 180.0
		explosion.scale_amount = 0.333
		var texture := load('res://assets/sprites/effects/sparkle%d.png' % [i + 1])
		explosion.texture = texture
		explosion.amount = 4
		
		pin.get_parent().add_child(explosion)
		explosion.global_position = box.global_rect().get_center()

func random_sparkle_explosions() -> Array:
	var sparkle1 := ExplosionTemplateScene.instance() as ExplosionParticles
	sparkle1.spread = 180.0
	sparkle1.scale_amount = 0.333
	sparkle1.amount = 5
	sparkle1.initial_velocity_random = 0.5
	sparkle1.texture = load(_random_sparkle_path())
	sparkle1.z_index = Aura.Z_INDEX_FRONT
	
	var sparkle2 := ExplosionTemplateScene.instance() as ExplosionParticles
	sparkle2.spread = 180.0
	sparkle2.scale_amount = 0.333
	sparkle2.amount = 5
	sparkle2.initial_velocity_random = 0.5
	sparkle2.texture = load(_random_sparkle_path())
	sparkle2.z_index = Aura.Z_INDEX_FRONT
	
	var glows := ExplosionTemplateScene.instance() as ExplosionParticles
	glows.spread = 180.0
	glows.scale_amount = 1.0
	glows.amount = 15
	glows.initial_velocity_random = 1.0
	glows.texture = load('res://assets/sprites/effects/glow_circle.png')
	glows.z_index = Aura.Z_INDEX_FRONT
	glows.hue_variation_random = 1.0
	glows.hue_variation = 0.5
	
	return [sparkle1, sparkle2, glows]

func _random_sparkle_path() -> String:
	var path := 'res://assets/sprites/effects/sparkle%d.png' % [randi() % 5 + 1]
	
	return path

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
	front.scale_amount = 0.5
	front.amount = 5
	front.spread = 35
	front.z_index = Aura.Z_INDEX_FRONT
	
	var back := ExplosionTemplateScene.instance() as ExplosionParticles
	back.texture = load('res://assets/sprites/effects/hero_smoke%d.png' % [RaNdom.randi_range(1, 7)])
	back.scale_amount = 0.5
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
	
	var floating_number := FloatingTextScene.instance() as FloatingText
	floating_number.value = value
	
	_add_floating_text_character(pin, parent, floating_number, 2.0)

func floating_text(pin: ArpeegeePinNode, text: String, parent: Node) -> void:
	assert(pin)
	assert(parent)
	
	var floating_text := FloatingTextScene.instance() as FloatingText
	floating_text.text = text
	
	_add_floating_text_character(pin, parent, floating_text, 3.0)

func _add_floating_text_character(pin: ArpeegeePinNode, parent: Node, floating_label: FloatingText, factor: float) -> void:
	var bounding_box := NodE.get_child(pin,  REferenceRect) as REferenceRect
	assert(bounding_box)
	parent.add_child(floating_label)
	
	var rect := bounding_box.global_rect()
	var label_start_position := rect.get_center() + Vector2.UP * rect.size.y / 4.0
	floating_label.global_position = label_start_position
	var distance_to_top := -(rect.position.y - label_start_position.y)
	floating_label.float_up(distance_to_top * factor)
