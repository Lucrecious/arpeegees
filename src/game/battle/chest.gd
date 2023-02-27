extends Control

onready var _top := $Chest/Bottom/Top as Control
onready var _glow := $Chest/Bottom/Glow as Control
onready var _chest := $Chest as Control
onready var _wallpaper_circle := $Chest/WallpaperCircle as WallpaperCircle
onready var _twitter_link := $'%TwitterLink' as LinkButton

func _ready() -> void:
	VisualServer.canvas_item_set_z_index(get_canvas_item(), 7)
	_glow.visible = false
	_glow.modulate.a = 0.0
	_top.visible = true
	
	_wallpaper_circle.visible = false
	
	_twitter_link.connect('pressed', self, '_on_twitter_link_pressed')

func _on_twitter_link_pressed() -> void:
	var twitter_link := 'https://www.twitter.com/%s' % [_wallpaper_circle.wallpaper.twitter]
	OS.shell_open(twitter_link)

func run() -> void:
	var animation := create_tween()
	animation.tween_interval(1.5)
	
	animation.tween_property(_top, 'rect_position', Vector2.UP * 150.0, 1.0)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	animation.parallel().tween_callback(_glow, 'set', ['visible', true])
	animation.parallel().tween_property(_glow, 'modulate:a', 1.0, 0.5)
	
	
	var wallpaper := create_tween()
	wallpaper.tween_interval(1.5)
	wallpaper.tween_property(_wallpaper_circle, 'modulate:a', 1.0, 0.5)
	wallpaper.tween_property(_wallpaper_circle, 'position', _wallpaper_circle.position, 0.5)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	wallpaper.parallel().tween_property(_wallpaper_circle, 'scale', _wallpaper_circle.scale, 0.5)
	
	wallpaper.tween_interval(1.0)
	
	var twitter_link_text := 'Artist Twitter: @%s' % [_wallpaper_circle.wallpaper.twitter]
	var chars_per_sec := 30.0
	var sec_to_show := twitter_link_text.length() / chars_per_sec
	
	wallpaper.tween_method(self, '_progress_link_button', 0.0, 1.0, sec_to_show, [twitter_link_text])
	
	_wallpaper_circle.visible = true
	_wallpaper_circle.position = Vector2.ZERO
	_wallpaper_circle.modulate.a = 0.0
	_wallpaper_circle.scale = Vector2.ONE * 0.01

func _progress_link_button(progress: float, text: String) -> void:
	if is_equal_approx(progress, 1.0):
		_twitter_link.text = text
	else:
		var new_text := text.substr(0, text.length() * progress)
		_twitter_link.text = new_text
