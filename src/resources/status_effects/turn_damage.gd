class_name StartTurnDamageStatusEffect
extends Node

export(int) var runs_alive := 1
export(int) var damage_per_run := 0

func run_start_turn_effect() -> void:
	var damage_receiver := NodE.get_child(
			NodE.get_ancestor(self, ArpeegeePinNode), DamageReceiver) as DamageReceiver
	damage_receiver.damage(damage_per_run)
	
	runs_alive -= 1
	
	if runs_alive > 0:
		return
	
	queue_free()
