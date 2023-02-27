class_name WallpaperCircle
extends Sprite


const MobileWallpapers := [
	preload('res://assets/wallpaper_previews/resources/allen-mobile-1.tres'),
	preload('res://assets/wallpaper_previews/resources/allen-mobile-2.tres'),
	preload('res://assets/wallpaper_previews/resources/bacun-mobile-1.tres'),
	preload('res://assets/wallpaper_previews/resources/cummings-mobile-1.tres'),
]

const DesktopWallpapers := [
	preload('res://assets/wallpaper_previews/resources/allen-desktop-1.tres'),
	preload('res://assets/wallpaper_previews/resources/bacun-desktop-1.tres'),
	preload('res://assets/wallpaper_previews/resources/cummings-desktop-1.tres'),
]

onready var _shader := material as ShaderMaterial

var wallpaper: WallpaperReward

func _ready() -> void:
	_update_outline()
	
	randomize()
	
	if GameFrameWebInterop.WebDict.is_on_mobile:
		wallpaper = MobileWallpapers[randi() % MobileWallpapers.size()]
	else:
		wallpaper = DesktopWallpapers[randi() % DesktopWallpapers.size()]
	
	texture = wallpaper.texture

func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event is InputEventMouseMotion:
		_update_outline()
	
	if event is InputEventMouseButton:
		if is_over(get_global_mouse_position()) and not event.pressed:
			_open_wallpaper_link()

func _update_outline() -> void:
	if is_over(get_global_mouse_position()):
		_shader.set_shader_param('line_color', Color.whitesmoke)
	else:
		_shader.set_shader_param('line_color', Color.black)

func is_over(position: Vector2) -> bool:
	var radius := (texture.get_size() * scale).x / 2.0
	return global_position.distance_squared_to(position) < (radius * radius)

func _open_wallpaper_link() -> void:
	if not OS.get_name() == 'HTML5':
		return
	
	var file_path := wallpaper.resource_path.get_file()
	var key := file_path.left(file_path.find_last('.'))
	
	var document := JavaScript.get_interface('document')
	document.openLinkByKey(key)
