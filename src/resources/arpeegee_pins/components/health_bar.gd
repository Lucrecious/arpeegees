extends Sprite

var _max_health := 0

onready var _progress_bar := $ProgressBar as Sprite
onready var _health := NodE.get_sibling(self, Health) as Health
onready var _actions := NodE.get_sibling(self, PinActions) as PinActions

func _ready() -> void:
	_max_health = _health.current
	_health.connect('changed', self, '_on_changed')
	
	_actions.connect('action_started', self, '_on_action_started')
	_actions.connect('action_ended', self, '_on_action_ended')

func _on_action_started() -> void:
	visible = false

func _on_action_ended() -> void:
	visible = true

func _on_changed() -> void:
	_progress_bar.scale.x = float(_health.current) / _max_health
