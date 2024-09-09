extends Control

enum Focus {
	Entry,
	Start,
	Exit
}

var _prevFocus : Focus
var _focus : Focus
var focus : Focus:
	get :
		return _focus
	set(value) :
		_prevFocus = _focus
		_focus = value
		focusChanged()

@onready var transitionsPlayer = $TransitionsPlayer
@onready var StartGameSound = $StartGameSound
@onready var MoveFocusSound = $MoveFocusSound


var inFadeOut = false

func _ready():
	_focus = Focus.Entry

func _process(delta):
	if Input.is_action_just_pressed("down"):
		match focus:
			Focus.Exit, Focus.Entry:
				focus = Focus.Start
			Focus.Start:
				focus = Focus.Exit
	if Input.is_action_just_pressed("up"):
		match focus:
			Focus.Start:
				focus = Focus.Exit
			Focus.Exit:
				focus = Focus.Start
	if Input.is_action_just_pressed("ui_accept"):
		match focus:
			Focus.Start:
				_on_start_pressed()
			Focus.Exit:
				_on_exit_pressed()

func focusChanged():
	MoveFocusSound.pitch_scale = randf_range(0.9, 1.1)
	MoveFocusSound.play()
	adjustAnimation()

func adjustAnimation():
	var string := ""
	match _prevFocus:
		Focus.Entry:
			string = "Entry-"
		Focus.Start:
			string = "Start-"
		Focus.Exit:
			string = "Exit-"
	match focus:
		Focus.Start:
			string = string + "Start"
		Focus.Exit:
			string = string + "Exit"
	
	transitionsPlayer.play(string)

func _on_start_pressed():
	if not inFadeOut:
		inFadeOut = true
		StartGameSound.play()
		transitionsPlayer.play("FadeOut")
		await transitionsPlayer.animation_finished
		GameManager.startGame()

func _on_exit_pressed():
	if not inFadeOut:
		inFadeOut = true
		transitionsPlayer.play("FadeOut")
		await transitionsPlayer.animation_finished
		GameManager.endGame()
