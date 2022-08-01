class_name Squisher
extends Node2D

signal height_factor_changed()
signal squish_factor_changed()

export(float, 0.0, 10.0) var height_factor := 1.0 setget _height_factor_set
func _height_factor_set(value: float) -> void:
	if is_equal_approx(value, height_factor):
		return
	
	height_factor = value
	emit_signal('height_factor_changed')

export(float) var squish_factor := 1.0 setget _squish_factor_set
func _squish_factor_set(value: float) -> void:
	if is_equal_approx(value, squish_factor):
		return

	squish_factor = value
	emit_signal('squish_factor_changed')

onready var _root_sprite := NodE.get_sibling(self, RootSprite) as RootSprite

func _ready() -> void:
	connect('height_factor_changed', self, '_on_height_factor_changed')
	_on_height_factor_changed()
	
	connect('squish_factor_changed', self, '_on_squish_factor_changed')
	_on_squish_factor_changed()

func _on_height_factor_changed() -> void:
	_update_scale()

func _on_squish_factor_changed() -> void:
	_update_scale()

func _update_scale() -> void:
	_root_sprite.scale.y = height_factor
	_root_sprite.scale.x = (1.0 / height_factor) * squish_factor
