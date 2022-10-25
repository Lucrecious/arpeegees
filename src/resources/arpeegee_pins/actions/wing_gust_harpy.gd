extends Node2D

signal text_triggered(translation_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/wing_gust_harpy.tres')

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var sounds := NodE.get_child(actioner, SoundsComponent) as SoundsComponent
	
	var gust := load('res://src/vfx/gust_harpy.tscn').instance() as CPUParticles2D
	gust.z_index = Aura.Z_INDEX_FRONT
	get_viewport().add_child(gust)
	gust.emitting = true
	
	var animation := create_tween()
	
	var switch_secs := [0.5, 0.3, 0.2]
	var speed_scales := [1.0, 2.0, 3.0]
	for i in 15:
		switch_secs.push_back(0.1)
		speed_scales.push_back(4.0)
	
	animation.tween_callback(sounds, 'play', ['Gust'])
	for i in switch_secs.size():
		var sec := switch_secs[i] as float
		var scale := speed_scales[i] as float
		animation.tween_callback(gust, 'set', ['speed_scale', scale])
		animation.tween_callback(sprite_switcher, 'change', ['winggust'])
		animation.tween_interval(sec)
		animation.tween_callback(sprite_switcher, 'change', ['idle'])
		animation.tween_interval(sec)
	
	var hit := false
	for t in targets:
		var hit_type := ActionUtils.add_attack(animation, actioner, t, modified_stats.magic_attack)
		if hit_type != ActionUtils.HitType.Miss:
			hit = true
	
	if hit:
		animation.tween_callback(sounds, 'play', ['GustHit'])
	else:
		print_debug('play miss sound here')
	
	animation.tween_callback(gust, 'set', ['emitting', false])
	animation.tween_interval(1.0)
	animation.tween_callback(object, callback)
	
	if hit:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_WING_GUST_USE')
	
	animation.tween_interval(gust.lifetime)
	animation.tween_callback(gust, 'queue_free')
