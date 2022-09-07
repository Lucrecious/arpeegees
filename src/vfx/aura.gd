extends Node

const Z_INDEX_FRONT := 1

const AuraTemplateScene := preload('res://src/resources/status_effects/aura.tscn')
const SweatScene := preload('res://src/vfx/sweat.tscn')

func create_sweat_aura(pin: ArpeegeePinNode) -> Array:
	var front := SweatScene.instance() as CPUParticles2D
	front.z_index = Z_INDEX_FRONT
	
	var bounding_box := NodE.get_child(pin, REferenceRect) as REferenceRect
	var rect := bounding_box.global_rect()
	front.position.y -= rect.size.y
	
	return [front]

func create_power_up_auras() -> Array:
	var front := AuraTemplateScene.instance() as AuraParticles
	front.texture = load('res://assets/sprites/effects/hero_smoke3.png')
	front.scale_amount = 0.3
	front.z_index = Z_INDEX_FRONT
	front.amount = 5
	
	var back := AuraTemplateScene.instance() as AuraParticles
	back.texture = load('res://assets/sprites/effects/hero_smoke4.png')
	back.scale_amount = 0.3
	back.amount = 5
	
	return [front, back]

func create_enraged_auras() -> Array:
	var front := AuraTemplateScene.instance() as AuraParticles
	front.texture = load('res://assets/sprites/effects/monster_enraged.png')
	front.scale_amount = 2.0
	front.z_index = Z_INDEX_FRONT
	front.amount = 3
	front.position.y -= 50.0
	
	var back := AuraTemplateScene.instance() as AuraParticles
	back.texture = load('res://assets/sprites/effects/monster_enraged.png')
	back.scale_amount = 2.0
	back.amount = 3
	back.position.y -= 50.0
	
	return [back, front]

func create_note_auras() -> Array:
	var front := AuraTemplateScene.instance() as AuraParticles
	front.texture = load('res://assets/sprites/effects/note2_vfx.png')
	front.scale_amount = 1.0
	front.z_index = Z_INDEX_FRONT
	front.amount = 3
	
	var back := AuraTemplateScene.instance() as AuraParticles
	back.texture = load('res://assets/sprites/effects/note1_vfx.png')
	back.scale_amount = 0.8
	back.amount = 3
	
	return [front, back]
