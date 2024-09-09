extends Node
class_name DialogManager

enum Display{
	Left,
	Right,
	Center,
	None
}

signal DialogStarted(name:String)
signal DialogEnded(name:String)
signal DialogAdvancable()

@export_group("External Helpers")
@export var left: SpeechBubble
@export var right: SpeechBubble
@export var center: SpeechBubble
@export var animationPlayer: AnimationPlayer

@export_group("", "")
@export var dialogs: Array[Dialog] =  []
@export var showAdvanceWaitTime : float = 2

@onready var advanceTimer : Timer = $AdvanceTimer
@onready var showAdvanceHintTimer : Timer = $ShowAdvanceHintTimer

var _currentDialog : Dialog = null
var _currentDisplay : SpeechBubble = null
var _dialogCounter := 0
var _running := false

var _advancable := false

func _ready():
	advanceTimer.timeout.connect(_autoAdvance)
	showAdvanceHintTimer.timeout.connect(_showAdvanceHint)

func _exit_tree():
	advanceTimer.timeout.disconnect(_autoAdvance)
	showAdvanceHintTimer.timeout.disconnect(_showAdvanceHint)

func _process(delta):
	if _advancable:
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("down"):
			advanceDialog()

func activateDialog(name):
	if not _running:
		var d = _getDialog(name)
		if d:
			_startDialog(d)
			advanceDialog()

func advanceDialog():
	advanceTimer.stop()
	showAdvanceHintTimer.stop()
	if _dialogCounter >= _currentDialog.sequence.size():
		_endDialog()
		return
	
	var action = _currentDialog.sequence[_dialogCounter]
	if action:
		_executeAction(action)
	_dialogCounter += 1

func _autoAdvance():
	advanceDialog()

func _showAdvanceHint():
	if _currentDisplay:
		_currentDisplay.showAdvance()
		_advancable = true
		DialogAdvancable.emit()

func _getDialog(name) -> Dialog:
	for d in dialogs:
		if d.name == name:
			return d
	return null

func _startDialog(d):
	_currentDialog = d
	_running = true
	_dialogCounter = 0
	if _currentDialog.pausePlay:
		GameManager.pausePlay()
	DialogStarted.emit(d.name)

func _endDialog():
	var name = _currentDialog.name
	var unpause = _currentDialog.pausePlay
	_currentDialog = null
	_currentDisplay = null
	_dialogCounter = 0
	_running = false
	_advancable = false
	_endAllDisplays()
	if unpause: 
		GameManager.unpausePlay
	DialogEnded.emit(name)

func _executeAction(act: DialogAction):
	if act.hideOtherDisplays:
		_endAllDisplays()
	
	match act.type:
		DialogAction.Type.TEXT:
			_executeTextAction(act)
		DialogAction.Type.WAIT:
			_executeWaitAction(act)
		DialogAction.Type.ANIMATION:
			_executeAnimationAction(act)
	
	advanceTimer.start(act.time)
	showAdvanceHintTimer.start()

func _executeTextAction(act:DialogAction):
	_currentDisplay = _getDisplay(act.display)
	if _currentDisplay:
		_currentDisplay.setText(act.text)
		_advancable = false

func _executeWaitAction(act:DialogAction):
	_advancable = false

func _executeAnimationAction(act:DialogAction):
	animationPlayer.play(act.text)

func _endAllDisplays():
	left.end()
	left.hideAdvance()
	right.end()
	right.hideAdvance()
	center.end()
	center.hideAdvance()
	_currentDisplay = null

func _getDisplay(dis: Display) -> SpeechBubble:
	match dis:
		Display.Left:
			return left
		Display.Right:
			return right
		Display.Center:
			return center
	return null
