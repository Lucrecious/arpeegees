class_name SpriteSwitcher
extends Node2D

export(String) var default_sprite := 'idle'
export(PoolStringArray) var exceptions := PoolStringArray([])

var _name_to_sprite := {}

onready var _sprites := NodE.get_sibling_by_name(self, 'Sprites') as Node2D

func _ready() -> void:
	for s in _sprites.get_children():
		if s.name in exceptions:
			continue
		_name_to_sprite[s.name.to_lower()] = s
	
	assert(default_sprite in _name_to_sprite)

func get_all_sprite_names() -> PoolStringArray:
	return PoolStringArray(_name_to_sprite.keys())

func sprite(name: String) -> Node2D:
	name = name.to_lower()
	var sprite := _name_to_sprite.get(name, _name_to_sprite[default_sprite]) as Node2D
	return sprite

func swap_map(one: String, other: String) -> void:
	one = one.to_lower()
	other = other.to_lower()
	
	var node := _name_to_sprite.get(one, null) as Node2D
	if not node:
		assert(false)
		return
	
	var other_node := _name_to_sprite.get(other, null) as Node2D
	if not other_node:
		assert(false)
		return
	
	_name_to_sprite[one] = other_node
	_name_to_sprite[other] = node
	
	if other_node.visible:
		other_node.visible = false
		node.visible = true
	elif node.visible:
		node.visible = false
		other_node.visible = true
	

func has_sprite(name: String) -> bool:
	var sprite := _name_to_sprite.get(name, null) as Node2D
	return sprite != null

func change(name: String) -> void:
	var sprite := sprite(name)
	for n in _name_to_sprite.values():
		n.visible = false
	sprite.visible = true
