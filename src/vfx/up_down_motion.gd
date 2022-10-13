extends Sprite

const rocks := [
	preload('res://assets/sprites/effects/rock2.png'),
	preload('res://assets/sprites/effects/rock3.png'),
	preload('res://assets/sprites/effects/rock4.png'),
]

func _ready():
	texture = rocks[randi() % rocks.size()]
	
	var tween := create_tween()
	
	tween.tween_property(self, 'position', Vector2.UP * 35.0, 1.0).as_relative()\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, 'position', Vector2.DOWN * 35.0, 1.0).as_relative()\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	
	tween.custom_step(randf())
	tween.set_loops()
