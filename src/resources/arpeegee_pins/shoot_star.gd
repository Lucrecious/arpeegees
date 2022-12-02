extends Node2D

onready var _start_star := $StartStar as AnimatedSprite
onready var _fly_sprite := $Sprite as AnimatedSprite
onready var _light_particles := ($Sprite/LightParticles as Node2D).get_children()

func _ready() -> void:
	_start_star.visible = true
	_fly_sprite.visible = false
	_fly()

const SEC_PER_FRAME := 1.0 / 30.0
func _fly() -> void:
	var animation := create_tween()
	
	animation.tween_property(_start_star, 'frame', 2, SEC_PER_FRAME * 3)
	animation.tween_callback(_start_star, 'set', ['visible', false])
	animation.tween_callback(_fly_sprite, 'set', ['visible', true])
	animation.tween_callback(ObjEct, 'group_call', [_light_particles, 'set', ['emitting', true]])
	
	animation.tween_property(_fly_sprite, 'frame', 1, SEC_PER_FRAME * 2)
	animation.tween_callback(_fly_sprite, 'set', ['position', _fly_sprite.position + Vector2.UP * 75.0])
	animation.tween_callback(_fly_sprite, 'play')
	animation.tween_property(_fly_sprite, 'position:y', -500.0, 0.35).as_relative()
	animation.tween_interval(2.0)
	animation.tween_callback(self, 'queue_free')
