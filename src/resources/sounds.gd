class_name SoundsComponent
extends Node

onready var _players := {}

func _ready() -> void:
	for c in get_children():
		if not c is AudioStreamPlayer:
			continue
		_players[c.name] = c

func play(name: String) -> void:
	var player := _players.get(name, null) as AudioStreamPlayer
	if not player:
		assert(false)
		return
	
	player.play()

func play_random(name: String, variations: int) -> void:
	# variations start a 1
	var random_number := 1 + randi() % variations
	var random_name := '%s%d' % [name, random_number]
	play(random_name)

func play_new(name: String) -> void:
	var player := _players.get(name, null) as AudioStreamPlayer
	player = player.duplicate()
	
	add_child(player)
	player.play()
	
	yield(player, 'finished')
	
	player.queue_free()

func play_new_random(name: String, variations: int) -> void:
	# variations start at 1
	var random_number := 1 + randi() % variations
	var random_name := '%s%d' % [name, random_number]
	play_new(random_name)
