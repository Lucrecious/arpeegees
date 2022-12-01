extends Area2D

onready var _health := NodE.get_sibling(self, Health) as Health

func _ready() -> void:
	_health.connect('changed', self, '_on_health_changed')

func _on_health_changed() -> void:
	if _health.current <= 0:
		get_child(0).set_deferred('disabled', true)
	else:
		get_child(0).set_deferred('disabled', false)
