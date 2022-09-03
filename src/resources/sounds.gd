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
		return
	
	player.play()

func play_new(name: String) -> void:
	var player := _players.get(name, null) as AudioStreamPlayer
	player = player.duplicate()
	
	add_child(player)
	player.play()
	
	yield(player, 'finished')
	
	player.queue_free()
