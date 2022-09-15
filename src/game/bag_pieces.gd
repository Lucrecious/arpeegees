extends Control

onready var _pieces := get_children()

var _speeds := []
var _scale_speed := []
var _directions := []

func _ready() -> void:
	set_physics_process(false)

func explode() -> void:
	set_physics_process(true)
	
	for _p in _pieces:
		_speeds.push_back(rand_range(1500.0, 2000.0))
		_directions.push_back(RaNdom.random_unit_vector())
		_scale_speed.push_back(rand_range(1.1, 2.0))
		
		var animation := create_tween()
		animation.tween_interval(0.55)
		animation.tween_property(_p, 'modulate:a', 0.0, 0.2)
	
	yield(get_tree().create_timer(0.75), 'timeout')
	
	set_physics_process(false)
	for p in _pieces:
		p.queue_free()
	
	_pieces.clear()

func _physics_process(delta: float) -> void:
	for i in _pieces.size():
		var p := _pieces[i] as Control
		var s := _speeds[i] as float
		var d := _directions[i] as Vector2
		var speed_scale := _scale_speed[i] as float
		
		p.rect_position += s * delta * d
		p.rect_scale *= speed_scale
		
		_speeds[i] = s * 1.5
