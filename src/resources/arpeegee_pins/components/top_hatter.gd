class_name TopHatter
extends Node2D


func enable(hat_number: int) -> void:
	assert(hat_number >= 0 and hat_number < 3)
	
	get_parent().move_child(self, get_parent().get_child_count() - 1)
	
	var sprite := get_child(hat_number) as Sprite
	sprite.visible = true
