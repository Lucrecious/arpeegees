extends Node2D

signal text_triggered(translation_key)

export(String) var spawn_position_hint_node := 'SpawnPositionHint'
export(PackedScene) var projectile_scene: PackedScene = null

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/heckin_good_song.tres')

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	for t in targets:
		var status_effects := NodE.get_child(t, StatusEffectsList) as StatusEffectsList
		var heckin_good_song_effect := HeckinGoodSongDancingEffect.new()
		status_effects.add_as_effects([heckin_good_song_effect])
	
	var animation := create_tween()
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_HECKIN_GOOD_SONG_USE_1')
	animation.tween_callback(object, callback)
