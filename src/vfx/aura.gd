extends Node

const Z_INDEX_FRONT := 1

const AuraTemplateScene := preload('res://src/resources/status_effects/aura.tscn')

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
