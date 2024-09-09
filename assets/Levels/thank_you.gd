extends CanvasLayer

@onready var SecretsTextLabel = $MarginContainer/RichTextLabel2
@onready var AdvanceAnimationPlayer = $AnimationPlayer

var inAnimation := false
var state := 0
var advanceToNextLevel := false

func _ready():
	var secretsFound = GameManager.numSecretsFound()
	var possibleSecrets = GameManager.numSecrets()
	advanceToNextLevel = GameManager.foundAllSecrets()
	
	SecretsTextLabel.text = "[center]HAVE YOU FOUND ALL THE SECRETS?\n" + str(secretsFound) + " / " + str(possibleSecrets)
	AdvanceAnimationPlayer.animation_finished.connect(endAnimation)

func _exit_tree():
	AdvanceAnimationPlayer.animation_finished.disconnect(endAnimation)

func _process(delta):
	if _advance() and not inAnimation:
		advanceAnimation()

func _advance():
	return Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("down") or Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or Input.is_action_just_pressed("up")

func advanceAnimation():
	if state == 0:
		inAnimation = true
		AdvanceAnimationPlayer.play("Advance1")
	elif state == 1:
		inAnimation = true
		if not advanceToNextLevel:
			AdvanceAnimationPlayer.play("Advance2")
		else:
			AdvanceAnimationPlayer.play("AdvanceNextLevel")
	elif state == 2:
		inAnimation = true
		AdvanceAnimationPlayer.play("End")

func endAnimation(name):
	if name == "Advance1":
		state = 1
	if name == "Advance2":
		state = 2
	if name == "End":
		GameManager.returnToMainMenu()
	if name == "AdvanceNextLevel":
		GameManager.nextLevel()
	inAnimation = false

func checkAdvanceLevel():
	if advanceToNextLevel:
		GameManager.nextLevel()
