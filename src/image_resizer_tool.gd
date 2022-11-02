tool
extends Node

export(bool) var _run := false setget _run_set
func _run_set(value: bool) -> void:
	if not value:
		return
	
	for n in get_parent().get_children():
		var sprite := n as Sprite
		if not sprite:
			continue
		
		var texture := sprite.texture
		if not texture:
			continue
		
		var texture_path := ProjectSettings.globalize_path(texture.resource_path)
		var scale_percent := sprite.scale.x * 3.0
		var command := '/usr/local/bin/magick'
		var args := [ 
			'"%s"' % [texture_path],
			'-resize %d%%' % [scale_percent * 100.0],
			'-filter Lanczos',
			'"%s"' % [texture_path]
		]
		
		var exit_code := OS.execute(command, args, true, [], true)
		
		if exit_code != 0:
			print('exit code: ', exit_code)
			return
		
		sprite.scale = Vector2.ONE / 3.0
		print('Scaled "%s" successfully.' % [sprite.name])
