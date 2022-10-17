extends Sprite


onready var _pin_actions := NodE.get_sibling(self, PinActions) as PinActions
onready var _original_alpha := self_modulate.a

func _ready() -> void:
	visible = false

func initialize() -> void:
	_pin_actions.connect('action_started', self, '_on_action_started')
	_pin_actions.connect('action_ended', self, '_on_action_ended')
	_appear()

func _on_action_started() -> void:
	_disappear()

func _on_action_ended() -> void:
	_appear()

var _animation: SceneTreeTween
func _disappear() -> void:
	if _animation:
		_animation.kill()
	
	_animation = create_tween()
	_animation.tween_property(self, 'self_modulate:a', 0.0, 0.25)
	_animation.tween_callback(self, 'set', ['visible', false])

func _appear() -> void:
	if _animation:
		_animation.kill()
	
	var animation := create_tween()
	animation.tween_callback(self, 'set', ['visible', true])
	animation.tween_callback(self, 'set', ['self_modulate:a', 0.0])
	animation.tween_property(self, 'self_modulate:a', _original_alpha, 0.25)
