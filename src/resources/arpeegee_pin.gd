class_name ArpeegeePin
extends Resource

enum Type {
	Player,
	NPC,
	MenuItem
}

enum Rarity {
	Common,
	Rare,
	UltraRare,
}

export(String) var nice_name := 'Arpeegee'
export(Type) var type := Type.NPC
export(Rarity) var rarity := Rarity.Common
