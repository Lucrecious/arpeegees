extends Node

const RANDOMNESS_SIZE_MIN := 15
const RANDOMNESS_SIZE_MAX := 25

var _critical_randomness := {}
var _evasion_randomness := {}

func is_critical(critical_stat: int) -> bool:
	return _next_critical(critical_stat)

func is_evading(evasion_stat: int) -> bool:
	return _next_miss(evasion_stat)

func _next_miss(evasion_stat: int) -> bool:
	assert(evasion_stat <= ModifiedPinStats.EVASION_MAX)
	
	var evasions := _evasion_randomness.get(evasion_stat, []) as Array
	
	if evasions.empty():
		var randomness_size := randomness_size()
		var amount_of_evasions := max(int(floor(_get_evasion_chance(evasion_stat) * randomness_size)), 1)
		var amount_of_hits := randomness_size - amount_of_evasions
		for i in amount_of_evasions:
			evasions.push_back(true)
		for i in amount_of_hits:
			evasions.push_back(false)
		evasions.shuffle()
		
		_evasion_randomness[evasion_stat] = evasions
	
	return evasions.pop_back()

func _get_evasion_chance(evasion_stat: int) -> float:
	var evasion_ratio := evasion_stat / float(ModifiedPinStats.EVASION_MAX)
	return float(lerp(0, 0.5, evasion_ratio))

func _next_critical(critical_stat: int) -> bool:
	assert(critical_stat <= ModifiedPinStats.CRITICAL_MAX)
	
	var criticals := _critical_randomness.get(critical_stat, []) as Array
	
	if criticals.empty():
		var randomness_size := randomness_size()
		var amount_of_criticals := max(int(floor(_get_critical_chance(critical_stat) * randomness_size)), 1)
		var amount_of_regulars := randomness_size - amount_of_criticals
		for i in amount_of_criticals:
			criticals.push_back(true)
		for i in amount_of_regulars:
			criticals.push_back(false)
		criticals.shuffle()
		
		_critical_randomness[critical_stat] = criticals
	
	return criticals.pop_back()

func _get_critical_chance(critical_stat: int) -> float:
	var critical_ratio := critical_stat / float(ModifiedPinStats.CRITICAL_MAX)
	return critical_ratio

func randomness_size() -> int:
	return RANDOMNESS_SIZE_MIN + randi() % (RANDOMNESS_SIZE_MAX - RANDOMNESS_SIZE_MIN)
