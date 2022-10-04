extends Control

const SWIPE_SPEED_PIXELS := 100.0
const SWIPE_ACCELERATION_PIXELS := 3000.0

var _swipe_speed_pixels := SWIPE_SPEED_PIXELS

onready var _bush_left := $BushLeft as Control
onready var _bush_right := $BushRight as Control

func _ready() -> void:
	set_physics_process(false)
	yield(get_tree().create_timer(0.5), 'timeout')
	set_physics_process(true)
	
	var fade_away := create_tween()
	fade_away.tween_interval(4.0)
	fade_away.tween_property(self, 'modulate:a', 0.0, 0.5)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
func _physics_process(delta: float) -> void:
	_swipe_speed_pixels += SWIPE_ACCELERATION_PIXELS * delta
	_bush_left.rect_position.x -= delta * _swipe_speed_pixels
	_bush_right.rect_position.x += delta * _swipe_speed_pixels
