class_name StateMachine
extends Node

signal transitioned(state_name)

@export var initial_state : State

@onready var state: State = initial_state

func _ready() -> void:
	await(owner.ready)
	for child in get_children():
		child.state_machine = self
	state.enter()

func _unhandled_input(event):
	state.handle_input(event)

func _process(delta):
	state.update(delta)

func _physics_process(delta):
	state.physics_update(delta)

func transition_to(target_state_name: String, msg: Dictionary = {}):
	if not has_node(target_state_name):
		return
	
	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	emit_signal("transitioned", state.name)
