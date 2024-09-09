extends Node2D
class_name SlimeStand

signal startingCutSceneFinished
signal endingCutSceneFinished
signal entryFinished
signal slimeArrived

@export var startWithSlime := true
@export var standOnLeft := true
@export var outro := false

@onready var general_animation_player = $GenerelAnimationPlayer
@onready var slime_animation_player = $SlimeAnimationPlayer
@onready var pipe_stand = $Bright/PipeStand


func _ready():
	if startWithSlime:
		slimeIdle()
	else:
		noSlime()
	if standOnLeft:
		pipe_stand.position = Vector2(-8,0)
		pipe_stand.scale = Vector2(1,1)
	else:
		pipe_stand.position = Vector2(8,0)
		pipe_stand.scale = Vector2(-1,1)
	if outro:
		general_animation_player.play("End_Level_State")



func startingCutscene():
	turnOnLight()
	await general_animation_player.animation_finished
	startingCutSceneFinished.emit()

func endingCutscene():
	turnOffLight()
	await general_animation_player.animation_finished
	endingCutSceneFinished.emit()

func startLevel():
	removeStopper()
	await general_animation_player.animation_finished
	applySpout()
	await general_animation_player.animation_finished
	slimeExitVial()
	await slime_animation_player.animation_finished
	entryFinished.emit()

func endLevel():
	slimeEnterVial()
	await slime_animation_player.animation_finished
	slimeIdle()
	removeSpout()
	await general_animation_player.animation_finished
	applyStopper()
	await general_animation_player.animation_finished
	slimeArrived.emit()

func turnOnLight():
	general_animation_player.play("Turn_Light_On")

func turnOffLight():
	general_animation_player.play("Turn_Light_Off")

func removeStopper():
	general_animation_player.play("Remove_Stopper")

func applyStopper():
	general_animation_player.play("Apply_Stopper")

func removeSpout():
	general_animation_player.play("Remove_Spout")

func applySpout():
	general_animation_player.play("Apply_Spout")

func slimeIdle():
	slime_animation_player.play("Idle")

func slimeExitVial():
	slime_animation_player.play("Exit_Vial")

func slimeEnterVial():
	slime_animation_player.play("Enter_Vial")

func noSlime():
	slime_animation_player.play("No_Slime")
