class_name CapRemover
extends Node


onready var _sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher
onready var _transformer := NodE.get_sibling(self, Transformer) as Transformer

func add_animation_on_hit(animation: SceneTreeTween, narrator_caller: Object) -> void:
	animation.tween_callback(_sprite_switcher, 'change', ['hatlesshurt'])
	animation.tween_interval(0.5)
	animation.tween_callback(_sprite_switcher, 'change', ['hatlessidle'])
	
	animation.tween_callback(_transformer, 'request_transform')
	
	ActionUtils.add_text_trigger(animation, narrator_caller, 'NARRATOR_RANGER_SHOOTS_OFF_MUSHBOY_HAT')
