class_name VFXNotesPair
extends Node2D

export(bool) var broken := false

var broken_notes := [
	'res://assets/sprites/effects/note6.png',
	'res://assets/sprites/effects/note7.png',
	'res://assets/sprites/effects/note8.png',
]

var regular_notes := [
	'res://assets/sprites/effects/note3.png',
	'res://assets/sprites/effects/note4.png',
	'res://assets/sprites/effects/note5.png',
]

onready var _note1 := $Note1/Note as Sprite
onready var _note2 := $Note2/Note as Sprite

func _ready() -> void:
	if broken:
		_set_random_notes(broken_notes)
	else:
		_set_random_notes(regular_notes)

func _set_random_notes(notes: Array) -> void:
	notes.shuffle()
	_note1.texture = load(notes[0])
	_note2.texture = load(notes[1])
