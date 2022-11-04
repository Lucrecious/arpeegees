extends Sprite

var _max_health := 0

onready var _progress_bar := $BarLine as Line2D
onready var _separator_line := $Line as Node2D
onready var _bar_point_start := _progress_bar.points[0].x
onready var _bar_point_end := _progress_bar.points[1].x

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
	var health_ratio := float(_health.current) / _modified_pin_stats.max_health
	var new_point := lerp(_bar_point_start, _bar_point_end, health_ratio) as float
	var y := _progress_bar.points[1].y
	_progress_bar.set_point_position(1, Vector2(new_point, y))
	
	var end_position := _progress_bar.to_global(_progress_bar.points[1])
	_separator_line.global_position = end_position
