extends Area2D

@export var targetCamera : Camera2D

func _ready():
	body_entered.connect(transition)

func _exit_tree():
	body_entered.disconnect(transition)

func transition(body):
	GameManager._currentRoom.transitionTo(targetCamera)
