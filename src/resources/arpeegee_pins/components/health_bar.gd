extends Sprite

var _max_health := 0

onready var _progress_bar := $ProgressBar as Sprite
onready var _health := NodE.get_sibling(self, Health) as Health
onready var _modified_pin_stats := NodE.get_sibling(self, ModifiedPinStats) as ModifiedPinStats
onready var _actions := NodE.get_sibling(self, PinActions) as PinActions

func _ready() -> void:
	_max_health = _health.current
	_modified_pin_stats.connect('changed', self, '_on_stats_changed')
	_health.connect('changed', self, '_on_stats_changed')
	_on_stats_changed()
	
	_actions.connect('action_started', self, '_on_action_started')
	_actions.connect('action_ended', self, '_on_action_ended')

func _on_action_started() -> void:
	visible = false

func _on_action_ended() -> void:
	visible = true

func _on_stats_changed() -> void:
	_progress_bar.scale.x = float(_health.current) / _modified_pin_stats.max_health
