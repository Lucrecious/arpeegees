extends Control

onready var _pieces := get_children()
onready var _pieces_positions := _positions_for_pieces(_pieces)

func _positions_for_pieces(pieces: Array) -> Array:
	var positions := []
	
	for p in pieces:
		positions.push_back(p.rect_position)
	
	return positions

var _speeds := []
var _scale_speed := []
var _directions := []

func _ready() -> void:
	set_physics_process(false)

func reset() -> void:
	_speeds.clear()
	_directions.clear()
	_scale_speed.clear()
	
	for i in _pieces.size():
		var p := _pieces[i] as Control
		var v := _pieces_positions[i] as Vector2
		p.rect_position = v
		p.rect_scale = Vector2.ONE
		p.modulate.a = 1.0
		

func explode() -> void:
	set_physics_process(true)
	
	for _p in _pieces:
		_speeds.push_back(rand_range(100.0, 200.0))
		_directions.push_back(RaNdom.random_unit_vector())
		_scale_speed.push_back(rand_range(1.1, 1.3))
		
		var animation := create_tween()
		animation.tween_interval(0.65)
		animation.tween_property(_p, 'modulate:a', 0.0, 0.1)
	
	yield(get_tree().create_timer(0.75), 'timeout')
	
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	for i in _pieces.size():
		var p := _pieces[i] as Control
		var s := _speeds[i] as float
		var d := _directions[i] as Vector2
		var speed_scale := _scale_speed[i] as float
		
		p.rect_position += s * delta * d
		p.rect_scale *= speed_scale
		var clamped_scale := min(3.0, p.rect_scale.x)
		p.rect_scale = Vector2.ONE * clamped_scale
		
		_speeds[i] = s * 1.5
