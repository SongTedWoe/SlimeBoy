extends Node2D
class_name Room

signal IntroReady
signal LevelReady
signal OutroReady

@export var introCamera : Camera2D
@export var levelCamera : Camera2D
@export var outroCamera : Camera2D
@export var transitionTime := 2.0
@export var levelTransitionTime := 0.1
@export var levelFadeOut := 0.0
@export var maxSpeed : int = 500
@export var player : Player
@export var introSlimeStand : SlimeStand
@export var outroSlimeStand : SlimeStand
@export var dialogManager : DialogManager
@export var levelMusic : AudioStreamPlayer
@export var outroSound : AudioStreamPlayer

@export_group("Sequence Override")
@export var sequenceOverride : bool
@export var SOturnOnLight := true
@export var SOentryDialog := true
@export var SOslimeVialExit := true
@export var SOcamTransLevel := true
@export var SOplayLevel := true
@export var SOcamTransOutro := true
@export var SOslimeVialEntry := true
@export var SOexitDialog := true
@export var SOturnOffLight := true


@onready var _transitionCamera = $TransitionCamera

var _transitioning = false
var _targetCamera : Camera2D
var _targetPosition : Vector2
var _targetZoom : Vector2
var _delPos : Vector2
var _delZoom : Vector2
var _toLevel = false
var _toOutro = false

func _ready():
	introCamera.make_current()
	introCamera.reset_smoothing()
	levelCamera.make_current()
	levelCamera.reset_smoothing()
	outroCamera.make_current()
	outroCamera.reset_smoothing()

func _process(delta):
	if _transitioning:
		_transitionCamera.position += _delPos * delta
		_transitionCamera.zoom += _delZoom * delta
		if _transitionCamera.position.distance_to(_targetPosition) < _delPos.length()*delta:
			_transitioning = false
			#Transitioning done
			if _toLevel:
				_toLevel = false
				startWithLevel()
			else:
				if _toOutro:
					_toOutro = false
					startWithOutro()
				else:
					_targetCamera.make_current()


func startWithIntro():
	introCamera.make_current()	
	IntroReady.emit()

func startWithLevel():
	levelCamera.make_current()
	LevelReady.emit()

func startWithOutro():
	outroCamera.make_current()
	OutroReady.emit()

func transitionToLevel():
	_setTransitionVariables(levelCamera, transitionTime)
	_transitioning = true
	_toLevel = true

func fadeOutLevelMusic():
	var tween = create_tween()
	tween.tween_property(levelMusic, "volume_db", -80, transitionTime)
	tween.tween_callback(endMusic)

func endMusic():
	levelMusic.stop()

func transitionToOutro():
	_setTransitionVariables(outroCamera, transitionTime)
	_transitioning = true
	_toOutro = true

func transitionTo(cam, time := -1.0):
	if cam and cam != get_viewport().get_camera_2d():
		if time == -1: time = levelTransitionTime
		_setTransitionVariables(cam, time)
		_transitioning = true

func _setTransitionVariables(to:Camera2D, time := -1.0):
	if time == -1: time = transitionTime
	var from :Camera2D = get_viewport().get_camera_2d()
	print("from: ", from, " | to: ", to)
	_targetCamera = to
	
	
	var fromPos = from.get_screen_center_position()
	var toPos = to.get_screen_center_position()
	
	_delPos = (toPos - fromPos) / time
	
	if _delPos.length() >= maxSpeed: 
		_delPos = _delPos.normalized() * maxSpeed
		time = (toPos - fromPos).length() / maxSpeed
	
	_delZoom = (to.zoom - from.zoom)/time
	
	_transitionCamera.position = fromPos
	_transitionCamera.zoom = from.zoom
	
	_targetPosition = toPos
	_targetZoom = to.zoom
	
	_transitionCamera.make_current()

func sequenceLevel(turnOnLight := true, entryDialog := true, slimeVialExit := true, camTransLevel := true, playLevel := true, camTransOutro := true, slimeVialEntry := true,  exitDialog := true, turnOffLight := true):
	if sequenceOverride:
		turnOnLight = turnOnLight and SOturnOnLight
		entryDialog = entryDialog and SOentryDialog
		slimeVialExit = slimeVialExit and SOslimeVialExit
		camTransLevel = camTransLevel and SOcamTransLevel
		playLevel = playLevel and SOplayLevel
		camTransOutro = camTransOutro and SOcamTransOutro
		slimeVialEntry = slimeVialEntry and SOslimeVialEntry
		exitDialog = exitDialog and SOexitDialog
		turnOffLight = turnOffLight and SOturnOffLight
	
	startWithIntro()
	
	#Turn On Light
	if turnOnLight:
		if introSlimeStand:
			introSlimeStand.startingCutscene()
			await introSlimeStand.startingCutSceneFinished
	
	#Entry Dialog
	if entryDialog:
		if dialogManager:
			dialogManager.activateDialog("Enter")
			await dialogManager.DialogEnded
	
	#Slime Vial Exit
	if slimeVialExit:
		if introSlimeStand:
			introSlimeStand.startLevel()
			await introSlimeStand.entryFinished
	
	#Cam Trans Level
	if camTransLevel:
		transitionToLevel()
		await LevelReady
	else:
		startWithLevel()
	
	if levelMusic:
		levelMusic.play()
	
	#Play Level
	if playLevel:
		if player:
			player.startLevel()
			await GameManager.LevelEnd
	
	if levelMusic:
		fadeOutLevelMusic()
	
	#Cam Trans Outro
	if camTransOutro:
		transitionToOutro()
		await OutroReady
	else:
		startWithOutro()
	
	#Slime Vial Entry
	if slimeVialEntry:
		if outroSlimeStand:
			outroSlimeStand.endLevel()
			await outroSlimeStand.slimeArrived
	
	#Exit Dialog
	if exitDialog:
		if dialogManager:
			dialogManager.activateDialog("Exit")
			await dialogManager.DialogEnded
	
	#Turn Off Light
	if turnOffLight:
		if outroSlimeStand:
			outroSlimeStand.endingCutscene()
			await outroSlimeStand.endingCutSceneFinished
	
	if outroSound:
		outroSound.play()
		await outroSound.finished
	
	if levelFadeOut > 0.0:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.BLACK, levelFadeOut)
		await tween.finished
	
	GameManager.nextLevel()
