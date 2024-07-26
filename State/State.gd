class_name State
extends Node

# We need virtual functions to call for general purpose and transitions
var state_machine

func handle_input(_event: InputEvent) -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass

func enter(_msg := {}) -> void:
	pass

func exit() -> void:
	pass
