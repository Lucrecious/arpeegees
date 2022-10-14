class_name SlipEffect

static func add_slip_effect(tween: SceneTreeTween, targets: Array) -> void:
	tween.tween_callback(_SlipEffect, '_add_slip_effect', [targets])

class _SlipEffect:
	static func _add_slip_effect(targets: Array) -> void:
		for t in targets:
			var actions := NodE.get_child(t, PinActions) as PinActions
			for n in actions.get_children():
				var slippable := NodE.get_child(n, BananSlippable, false) as BananSlippable
				if slippable:
					slippable.is_slipping = true
