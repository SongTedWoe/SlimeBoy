class_name Spring extends Node2D

@export var Strength := 200.0
@export var direction := Vector2.UP

@onready var Animation_Player := $AnimationPlayer

func playSpringAnimation():
	Animation_Player.play("Spring")
