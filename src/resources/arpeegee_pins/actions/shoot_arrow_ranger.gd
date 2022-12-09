extends Node2D

signal text_triggered(narration_key)

enum Type {
	Regular,
	OnFire,
}

export(Type) var type := Type.Regular

onready var _arrow := $Arrow as Node2D

var _boosted := false
func boost() -> void:
	_boosted = true

func pin_action() -> PinAction:
	if type == Type.Regular:
		return preload('res://src/resources/actions/arrow_zip_ranger.tres')
	elif type == Type.OnFire:
		return preload('res://src/resources/actions/arrows_en_fuego_ranger.tres')
	assert(false)
	return null

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.4)
	
	var sounds := NodE.get_child(actioner, SoundsComponent)
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['attack'])
	animation.tween_callback(_arrow, 'set', ['visible', true])
	
	if type == Type.OnFire:
		animation.tween_callback(sounds, 'play', ['ArrowEnFuegoWindUp'])
	
	animation.tween_interval(0.75)
	if type == Type.OnFire:
		animation.tween_interval(0.5)
	
	animation.tween_callback(sounds, 'play', ['ArrowZip'])
	
	var target_box := NodE.get_child(target, REferenceRect) as REferenceRect
	var target_position := target_box.global_rect().get_center()
	animation.tween_property(_arrow, 'global_position', target_position, 0.1)
	
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	
	var attack_amount := modified_stats.attack
	
	var cap_remover := NodE.get_child(target, CapRemover, false) as CapRemover
	
	var hit_type := ActionUtils.HitType.Miss as int
	if not cap_remover:
		hit_type = ActionUtils.add_attack(animation, actioner, target, attack_amount)
	
	animation.tween_callback(VFX, 'physical_impactv', [actioner, target_position])
	
	if cap_remover:
		cap_remover.add_animation_on_hit(animation, self)
	
	# doesn't affect banan because it gets turned into Banan Foster
	if type == Type.OnFire and hit_type != ActionUtils.HitType.Miss and target.filename.get_file() != 'banan.tscn':
		var burn_status_effect := EffectFunctions.create_burn_status_effect(modified_stats.attack)
		var list := NodE.get_child(target, StatusEffectsList) as StatusEffectsList
		animation.tween_callback(list, 'add_instance', [burn_status_effect])
	
	animation.tween_callback(_arrow, 'set', ['visible', false])
	animation.tween_callback(_arrow, 'set', ['global_position', _arrow.global_position])
	
	if _boosted:
		var ghostsword := get_parent().get_node('MagicGhostSword/GhostSword')
		ghostsword.add_attack(animation, actioner, [target], 1)
	
	if not cap_remover:
		if type == Type.Regular:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_ARROW_ZIP_USE')
		elif type == Type.OnFire:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_ARROWS_EN_FUEGO_USE')
			if hit_type != ActionUtils.HitType.Miss:
				ActionUtils.add_text_trigger(animation, self, 'NARRATOR_ARROWS_EN_FUEGO_HIT_ENEMY')
	
	if type == Type.OnFire and hit_type != ActionUtils.HitType.Miss and target.filename.get_file() == 'banan.tscn':
		var transformer := target.get_node('FlameTransformer') as Transformer
		animation.tween_callback(transformer, 'request_transform')
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_BANAN_TURNS_INTO_BANAN_FOSTER_FROM_FIRE')
		
	
	animation.tween_interval(0.75)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)
