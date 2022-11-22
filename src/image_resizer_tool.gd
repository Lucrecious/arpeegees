tool
class_name ImageResizerTool
extends Node

export(PoolStringArray) var _exceptions := PoolStringArray([])
export(PoolStringArray) var _onlys := PoolStringArray([])

export(bool) var _run := false setget _run_set
func _run_set(value: bool) -> void:
	if not value:
		return
	
	for n in NodE.get_children_recursive(get_parent(), Sprite):
		var sprite := n as Sprite
		if not sprite:
			continue
		
		if not _onlys.empty() and not sprite.name in _onlys:
			continue
		
		if sprite.name in _exceptions:
			continue
		
		var texture := sprite.texture
		if not texture:
			continue
		
		var texture_path := ProjectSettings.globalize_path(texture.resource_path)
		var scale_percent := sprite.scale.x * 3.0
		var command := '/Users/lucrecious/dev/project_arpeegees/arpeegees/resize_images'
		var args := [
			texture_path,
			'%d' % [scale_percent * 100.0]
		]
		
		var full_command := PoolStringArray([command] + args).join(' ')
		print('Running: %s' % [full_command])
		
		var output := []
		var exit_code := OS.execute(command, args, true, output, true)
		
		print(output)
		if exit_code != 0:
			print('exit code: ', exit_code)
			return
		
		sprite.scale = Vector2.ONE / 3.0
		print('Scaled "%s" successfully.' % [sprite.name])
		print()
		print()
