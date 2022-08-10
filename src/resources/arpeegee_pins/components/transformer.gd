class_name Transformer
extends Node

signal transform_requested()

export(PackedScene) var transform_scene: PackedScene = null

func request_transform() -> void:
	emit_signal('transform_requested')
