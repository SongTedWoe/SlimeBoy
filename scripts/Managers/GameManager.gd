extends Node
#class_name GameManager

signal RoomChanged
signal LevelReset
signal LevelStart
signal LevelEnd

@export var _levelOrder: Array[PackedScene]
@export var _restingLevel : PackedScene
@export var _endScene : PackedScene
@export var managers: Array[Manager]
@export var secretCounter: Array[bool]

@export_group("LevelSequence")
@export var turnOnLight := true
@export var entryDialog := true
@export var slimeVialExit := true
@export var camTransLevel := true
@export var playLevel := true
@export var camTransOutro := true
@export var slimeVialEntry := true
@export var exitDialog := true
@export var turnOffLight := true

var _currentScene : Node
var _currentLevelIndex: int
var _currentPlayer : Player
var _currentRoom : Room

func _ready():
	var root = get_tree().root
	_currentScene = root.get_child(root.get_child_count() - 1)
	print("_currentScene is: ", _currentScene)
	_addManagers()
	#_showCurrentTree()
	if _currentScene is Room:
		call_deferred("sequenceLevel", _currentScene)
		_currentRoom = _currentScene

func goToScene(path):
	call_deferred("_goToScene", path)

func _goToScene(path):
	_resetManagers()
	
	_currentScene.free()
	var s = ResourceLoader.load(path)
	_currentScene = s.instantiate()
	get_tree().root.add_child(_currentScene)
	get_tree().current_scene = _currentScene
	
	if _currentScene is Room:
		_currentRoom = _currentScene
		sequenceLevel(_currentScene)
	#_showCurrentTree()

func reset():
	call_deferred("_reset")

func _reset():
	get_tree().reload_current_scene()
	_resetManagers()
	if _currentScene is Room:
		_currentRoom = _currentScene
		sequenceReset(_currentScene)
	LevelReset.emit()

func _resetManagers():
	get_tree().call_group(&"Manager", "reset")

func startLevel():
	LevelStart.emit()

func endLevel():
	LevelEnd.emit()
	if not _currentScene is Room:
		nextLevel()

func nextLevel():
	print("Next Level called")
	_currentLevelIndex += 1
	if _currentLevelIndex < _levelOrder.size():
		goToScene(_levelOrder[_currentLevelIndex].resource_path)
	else:
		returnToMainMenu()
	RoomChanged.emit()

func startGame():
	_currentLevelIndex = 0
	for i in range(secretCounter.size()):
		secretCounter[i] = false
	goToScene(_levelOrder[0].resource_path)

func endGame():
	get_tree().quit()

func returnToMainMenu():
	goToScene(_endScene.resource_path)

func _addManagers():
	var root = get_tree().root
	_addManagerRec(root)

func _addManagerRec(n):
	if n:
		if n is Manager and not managers.has(n):
			managers.append(n)
		if n.get_child_count() != 0:
			var children = n.get_children()
			for child in children:
				_addManagerRec(child)

func _showCurrentTree():
	print(get_tree().root.get_tree_string_pretty())

func sequenceLevel(r:Room):
	r.sequenceLevel(turnOnLight, entryDialog, slimeVialExit, camTransLevel, playLevel, camTransOutro, slimeVialEntry, exitDialog, turnOffLight)

func sequenceReset(r:Room):
	r.sequenceLevel(false, false, false, false, playLevel, camTransOutro, slimeVialEntry, exitDialog, turnOffLight)

func registerPlayer(p:Player):
	_currentPlayer = p
	if not _currentScene is Room:
		p.startLevel()

func pausePlay():
	_currentPlayer.pausePlay()

func unpausePlay():
	_currentPlayer.unpausePlay()

func getSecret(i):
	secretCounter[i] = true

func numSecrets():
	return secretCounter.size()

func numSecretsFound():
	var c = 0
	for f in secretCounter:
		if f: c += 1
	return c

func foundAllSecrets():
	if numSecretsFound() == secretCounter.size():
		return true
	return false
