class_name ActionUtils

static func get_closest_adjecent_position(actioner: Node2D, target: Node2D) -> Vector2:
	var actioner_bounding_box := NodE.get_child(actioner, REferenceRect) as REferenceRect
	var target_bounding_box := NodE.get_child(target, REferenceRect) as REferenceRect
	
	var actioner_rect := actioner_bounding_box.global_rect()
	var target_rect := target_bounding_box.global_rect()
	
	var away_direction := sign(actioner_rect.get_center().x - target_rect.get_center().x)
	
	var position := target_rect.get_center()
	position += Vector2.DOWN * (target_rect.size.y / 2.0)
	position += away_direction * Vector2.RIGHT * (target_rect.size.x / 2.0)
	position += away_direction * Vector2.RIGHT * (actioner_rect.size.x / 2.0)
	position += Vector2.UP * (actioner_rect.size.y / 2.0)
	
	return position - actioner_rect.get_center()
