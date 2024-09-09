class_name Spring extends Node2D

@export var springData : SpringData

@onready var Animation_Player := $AnimationPlayer
@onready var audioPlayer = $AudioStreamPlayer2D


func playSpringAnimation():
	Animation_Player.play("Spring")
	audioPlayer.play()

func getSpringData() -> SpringData:
	return springData
