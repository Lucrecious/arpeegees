class_name ArpeegeePin
extends Resource

enum Type {
	Player,
	NPC,
	MenuItem
}

enum Rarity {
	Common,
	Uncommon,
	Rare,
	UltraRare,
}

export(Type) var type := Type.NPC
export(Rarity) var rarity := Rarity.Common
export(String, FILE) var scene_path := ''
export(bool) var pickable := true
