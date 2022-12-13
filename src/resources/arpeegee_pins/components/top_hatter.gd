class_name TopHatter
extends Node2D

var hat_number := -1

func remove_hat() -> void:
	if hat_number < 0:
		return
	
	var sprite := get_child(hat_number) as Sprite
	var fade_out := create_tween()
	fade_out.tween_property(sprite, 'modulate:a', 0.0, 0.3)

var _enabled := false
func enable(hat_number: int) -> void:
	if _enabled:
		return
	
	_enabled = true
	assert(hat_number >= 0 and hat_number < 3)
	
	self.hat_number = hat_number
	
	get_parent().move_child(self, get_parent().get_child_count() - 1)
	
	var sprite := get_child(hat_number) as Sprite
	sprite.visible = true
