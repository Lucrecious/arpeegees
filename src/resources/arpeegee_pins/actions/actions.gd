class_name PinActions
extends Node2D

signal action_started()
signal action_started_with_action_node()
signal action_ended()

onready var _parent := get_parent() as Node2D
onready var _bounding_box := NodE.get_sibling(self, REferenceRect) as REferenceRect

var _is_running_action := false
var _is_moveless := false

var _enabled := false
func enable() -> void:
	if _enabled:
		return
	
	_enabled = true

func disable() -> void:
	if not _enabled:
		return
	
	_enabled = false

func _ready() -> void:
	assert(_parent)

func is_running_action() -> bool:
	return _is_running_action

func set_moveless(is_moveless: bool) -> void:
	_is_moveless = is_moveless

func get_pin_action_nodes(check_if_blocked := true) -> Array:
	if _is_moveless:
		return []
	
	var pin_action_nodes := []
	
	for child in get_children():
		if not child.has_method('pin_action'):
			continue
		
		if check_if_blocked and child.has_method('is_blocked') and child.is_blocked():
			continue
		
		pin_action_nodes.push_back(child)
	
	return pin_action_nodes

func run_action_with_targets(action_name: String, targets: Array, multiple: bool) -> void:
	var node := NodE.get_child_by_name(self, action_name)
	
	if not node:
		print_debug('%s failed to %s, signals will not be called!' % [_parent.name, action_name])
		return
	
	if not node.has_method('run'):
		print_debug('%s does not have a run method, signals will not be called!' % [node.get_path()])
		return
	
	_is_running_action = true
	
	var can_attack := true
	
	if _parent.filename.get_file() == 'mushboy.tscn':
		var mesmerized := NodE.get_child(_parent, Mesmerized, false) as Mesmerized
		if mesmerized and mesmerized.is_mesmerized() and randf() < 0.5:
			can_attack = false
			
			var mesmerized_animation := create_tween()
			mesmerized_animation.tween_interval(0.35)
			
			ActionUtils.add_text_trigger(mesmerized_animation, node, 'NARRATOR_MUSHBOY_CANT_ATTACK_MESMERIZED')
			
			mesmerized_animation.tween_callback(self, '_on_action_node_finished')
	
	var parent_effects_list := NodE.get_child(_parent, StatusEffectsList) as StatusEffectsList
	if parent_effects_list.count_tags(StatusEffectTag.Fear) and randf() < 0.5:
		can_attack = false
		
		var fear_animation := create_tween()
		fear_animation.tween_interval(0.35)
		
		if _parent.filename.get_file() == 'blobbo.tscn':
			ActionUtils.add_text_trigger_ordered(fear_animation, node, 'NARRATOR_BLOBBO_CANT_ATTACK_DUE_TO_FEAR_', 5, 1_000_000)
		else:
			ActionUtils.add_text_trigger(fear_animation, node, 'NARRATOR_CANT_ATTACK_DUE_TO_FEAR')
		
		fear_animation.tween_callback(self, '_on_action_node_finished')
	
	# extra handling for things that can cause attack to miss
	elif targets.size() == 1 and targets[0].filename.get_file() == 'mushboy.tscn':
		var status_effects_list := NodE.get_child(targets[0], StatusEffectsList) as StatusEffectsList
		if status_effects_list.count_tags(StatusEffectTag.Bounce) > 0:
			can_attack = false
			
			var miss_animation := create_tween()
			
			miss_animation.tween_interval(0.5)
			
			ActionUtils.add_text_trigger(miss_animation, node, 'NARRATOR_MUSHBOY_EVADE_IN_BOUNCE')
			
			miss_animation.tween_callback(self, '_on_action_node_finished')
	elif targets.size() > 0:
		var mushboy = null
		for t in targets:
			if t.filename.get_file() == 'mushboy.tscn':
				var status_effects_list := NodE.get_child(t, StatusEffectsList) as StatusEffectsList
				if status_effects_list.count_tags(StatusEffectTag.Bounce) > 0:
					mushboy = t
				break
		
		if mushboy:
			targets.erase(mushboy)
	
	if can_attack:
		var slippable := NodE.get_child(node, BananSlippable, false) as BananSlippable
		if slippable and slippable.is_activated():
			var slip_animation := slippable.run_action_with_targets(_parent, targets)
			slip_animation.tween_callback(self, '_on_action_node_finished')
		else: # main functionality
			if targets.empty():
				node.run(_parent, self, '_on_action_node_finished')
			elif targets.size() == 1 and not multiple:
				node.run(_parent, targets[0], self, '_on_action_node_finished')
			else:
				node.run(_parent, targets, self, '_on_action_node_finished')
	
	emit_signal('action_started')
	emit_signal('action_started_with_action_node', node)

func run_action(action_name: String) -> void:
	run_action_with_targets(action_name, [], false)

func _on_action_node_finished() -> void:
	_is_running_action = false
	emit_signal('action_ended')
