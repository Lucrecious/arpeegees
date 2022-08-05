class_name StatPopup
extends Panel

onready var _name := $'%Name' as Label
onready var _health := $'%Health' as Label
onready var _attack := $'%Attack' as Label
onready var _magic_attack := $'%MagicAttack' as Label
onready var _defence := $'%Defence' as Label
onready var _magic_defence := $'%MagicDefence' as Label
onready var _evasion := $'%Evasion' as Label
onready var _critical := $'%Critical' as Label

onready var _name_format := _name.text
onready var _health_format := _health.text
onready var _attack_format := _attack.text
onready var _magic_attack_format := _magic_attack.text
onready var _defence_format := _defence.text
onready var _magic_defence_format := _magic_defence.text
onready var _evasion_format := _evasion.text
onready var _critical_format := _critical.text

func apply_pin(pin: ArpeegeePinNode) -> void:
	_name.text = _name_format % [pin.nice_name]
	
	var stats := StatComputer.get_modified_stats(pin)
	
	if stats.empty():
		assert(false)
		return
	
	var health := NodE.get_child(pin, Health) as Health
	_health.text = _health_format % [health.current, stats[StatModifier.Type.MaxHealth]]
	
	var attack := stats[StatModifier.Type.Attack] as int
	var magic_attack := stats[StatModifier.Type.MagicAttack] as int
	var defence := stats[StatModifier.Type.Defence] as int
	var magic_defence := stats[StatModifier.Type.MagicDefence] as int
	var evasion := stats[StatModifier.Type.Evasion] as int
	var critical := stats[StatModifier.Type.Critical] as int
	
	_attack.text = _attack_format % [attack]
	_magic_attack.text = _magic_defence_format % [magic_attack]
	_defence.text = _defence_format % [defence]
	_magic_defence.text = _magic_defence_format % [magic_defence]
	_evasion.text = _evasion_format % [evasion]
	_critical.text = _critical_format % [critical]

