class_name ArpeegeePinNode
extends Node2D

export(String) var nice_name := 'Arpeegee'

export(Resource) var _resource_set: Resource = null

onready var resource := _resource_set as ArpeegeePin

onready var _start_animation := $StartAnimation as Node2D
onready var _light_down := _start_animation.get_node('LightDown') as Sprite
onready var _light_explode := _start_animation.get_node('LightExplode') as AnimatedSprite
onready var _light_particles := _start_animation.get_node('LightParticles').get_children()
onready var _root_sprite := Components.root_sprite(self)
onready var _hp_bar := get_node('HealthBar') as Node2D

func _ready() -> void:
	_light_down.visible = false
	if not resource:
		print_debug('warning: resource missing')


func emit_stars() -> void:
	_hp_bar.visible = false
	_light_explode.frame = 0
	_light_down.visible = true
	_root_sprite.visible = false
	ObjEct.group_call(_light_particles, 'set', ['emitting', true])

const SEC_PER_FRAME := 0.05
const SHAKE_OFFSETS := [7.0, -7.0]
func post_drop_initialization() -> void:
	_light_down.visible = false
	stop_star_emission()
	
	var animation := create_tween()
	animation.tween_property(_light_explode, 'frame', 2, SEC_PER_FRAME * 3)
	animation.tween_callback(_root_sprite, 'set', ['visible', true])
	
	animation.tween_callback(self, '_do_bounce')
	
	animation.tween_property(_light_explode, 'frame', 9, SEC_PER_FRAME * 7)
	
	animation.tween_interval(1.0)
	
	animation.tween_callback(_hp_bar, 'set', ['visible', true])
	var hp_position := _hp_bar.position
	for i in 5:
		animation.tween_property(_hp_bar, 'position:y', hp_position.y + SHAKE_OFFSETS[i % SHAKE_OFFSETS.size()], 0.04)
	
	animation.tween_callback(_hp_bar, 'set', ['position', hp_position])

func _do_bounce() -> void:
	var animation := create_tween()
	
	var squashes := [0.6, 1.2, 0.8, 1.1, 1.0]
	var last_sqaush := 1.0
	var easing := Tween.EASE_OUT
	for i in squashes.size():
		var s := squashes[i] as float
		animation.tween_method(self, '_squash_param', last_sqaush, s, 0.1)\
				.set_ease(easing).set_trans(Tween.TRANS_QUAD)
		last_sqaush = s
		easing = Tween.EASE_IN_OUT

func _squash_param(value: float) -> void:
	_root_sprite.material.set_shader_param('squash', value)

func stop_star_emission() -> void:
	ObjEct.group_call(_light_particles, 'set', ['emitting', false])

