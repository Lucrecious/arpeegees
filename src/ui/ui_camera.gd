class_name UICamera
extends Node2D

export(NodePath) var _control_path := NodePath()
export(float) var hide_hud_threshold := 305.0

onready var _control := NodE.get_node(self, _control_path, Control) as Control
onready var _game_visibility_notifier := $'%GameVisibilityNotifier' as VisibilityNotifier2D
onready var _battle := $'%Battle' as BattleScreen
onready var _original_bottom_bar_position := _battle.bottom_bar.rect_position

const JAVASCRIPT_BUTTON_LEFT := 0
var _on_browser_scroll_js_callback := JavaScript.create_callback(self, '_on_browser_scroll')
var _on_browser_mousedown_js_callback := JavaScript.create_callback(self, '_on_browser_mousedown')
var _on_browser_mouseup_js_callback := JavaScript.create_callback(self, '_on_browser_mouseup')

var _web_scroll_overlay
onready var _original_canvas_transform := _control.get_viewport().canvas_transform

var _using_web_scroll := false

func _ready() -> void:
	_game_visibility_notifier.connect('viewport_entered', self, '_on_viewport_entered')
	_game_visibility_notifier.connect('viewport_exited', self, '_on_viewport_exited')
	
	if OS.get_name() == 'HTML5':
		_using_web_scroll = true
		# move everything down
		var offset_y := -_control.rect_position.y
		get_parent().rect_position.y += offset_y
		
		var document := JavaScript.get_interface('document')
		_web_scroll_overlay = document.getElementById('scroll-overlay')
		_web_scroll_overlay.addEventListener('scroll', _on_browser_scroll_js_callback)
		_web_scroll_overlay.addEventListener('mousedown', _on_browser_mousedown_js_callback)
		_web_scroll_overlay.addEventListener('mouseup', _on_browser_mouseup_js_callback)

func _on_browser_scroll(event):
	var scroll_top := _web_scroll_overlay.scrollTop as int
	var viewport := _control.get_viewport()
	viewport.canvas_transform = _original_canvas_transform.translated(-Vector2.DOWN * scroll_top)

func _on_browser_mousedown(args: Array):
	var event = args[0]
	if event.button != JAVASCRIPT_BUTTON_LEFT:
		return
	
	var mousedown := _create_left_mouse_event(true)
	get_tree().input_event(mousedown)

func _on_browser_mouseup(args: Array):
	var event = args[0]
	if event.button != JAVASCRIPT_BUTTON_LEFT:
		return
	
	var mouseup := _create_left_mouse_event(false)
	get_tree().input_event(mouseup)

func _create_left_mouse_event(pressed) -> InputEventMouseButton:
	var mouse_button := InputEventMouseButton.new()
	mouse_button.button_index = BUTTON_LEFT
	mouse_button.button_mask = BUTTON_MASK_LEFT
	mouse_button.pressed = pressed
	
	var position := _last_mouse_position
	mouse_button.position = _last_mouse_global_position
	mouse_button.global_position = position
	
	return mouse_button

func _on_viewport_entered(viewport: Viewport) -> void:
	_show_hud()

func _on_viewport_exited(viewport: Viewport) -> void:
	_hide_hud()

var _hide_show_tween: SceneTreeTween
var _mute_play_tween: SceneTreeTween
func _hide_hud() -> void:
	if _hide_show_tween:
		_hide_show_tween.kill()
		_hide_show_tween = null
	
	if _mute_play_tween:
		_mute_play_tween.kill()
		_mute_play_tween = null
	
	_hide_show_tween = _battle.bottom_bar.create_tween()
	_hide_show_tween.tween_property(_battle.bottom_bar, 'rect_position:y',
			_original_bottom_bar_position.y + _battle.bottom_bar.rect_size.y + 100.0, 0.5)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	_hide_show_tween.tween_property(_battle.get_narrator(), 'rect_position:y',
			_battle.get_original_narrator_position().y - _battle.get_narrator().rect_size.y - 100.0, 0.5)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	var master_index := AudioServer.get_bus_index('Master')
	_mute_play_tween = create_tween()
	_mute_play_tween.tween_method(self, '_set_volume_on_bus', 0.0, -30.0, 1.0, [master_index])\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_mute_play_tween.tween_callback(AudioServer, 'set_bus_mute', [master_index, true])

func _show_hud() -> void:
	if _hide_show_tween:
		_hide_show_tween.kill()
		_hide_show_tween = null
	
	if _mute_play_tween:
		_mute_play_tween.kill()
		_mute_play_tween = null
	
	_hide_show_tween = _battle.bottom_bar.create_tween()
	_hide_show_tween.tween_property(_battle.bottom_bar, 'rect_position:y',
			_original_bottom_bar_position.y, 0.5)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	_hide_show_tween.tween_property(_battle.get_narrator(), 'rect_position:y',
		_battle.get_original_narrator_position().y, 0.5)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	var master_index := AudioServer.get_bus_index('Master')
	_mute_play_tween = create_tween()
	_mute_play_tween.tween_callback(AudioServer, 'set_bus_mute', [master_index, false])
	_mute_play_tween.tween_method(self, '_set_volume_on_bus', -30.0, 0.0, 1.0, [master_index])\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _set_volume_on_bus(volume_db: float, index: int) -> void:
	AudioServer.set_bus_volume_db(index, volume_db)

var _last_mouse_position := Vector2.ZERO
var _last_mouse_global_position := Vector2.ZERO
func _input(event: InputEvent) -> void:
	if _using_web_scroll:
		if event is InputEventMouseMotion:
			_last_mouse_position = event.position
			_last_mouse_global_position = event.global_position
		return
	
	var viewport := _control.get_viewport()
	
	if event is InputEventPanGesture:
		var pan_gesture := event as InputEventPanGesture
		var distance := pan_gesture.delta * 100.0 * Vector2.UP
		viewport.canvas_transform = viewport.canvas_transform.translated(distance)
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.pressed:
			var distance := Vector2.ZERO
			if mouse_button.button_index == BUTTON_WHEEL_UP:
				distance = Vector2.DOWN * 25.0
			elif mouse_button.button_index == BUTTON_WHEEL_DOWN:
				distance = Vector2.UP * 25.0
			
			if not distance.is_equal_approx(Vector2.ZERO):
				viewport.canvas_transform = viewport.canvas_transform.translated(distance)
	
	var rect := _control.get_global_rect()
	var viewport_size := get_viewport_rect().size
	
	if viewport.canvas_transform.origin.y < -rect.end.y + viewport_size.y:
		viewport.canvas_transform.origin.y = -rect.end.y + viewport_size.y

	if viewport.canvas_transform.origin.y > -rect.position.y:
		viewport.canvas_transform.origin.y = -rect.position.y
	

