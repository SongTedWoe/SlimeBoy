extends Control
class_name SpeechBubble

@onready var _richTextLabel = $MarginContainer/RichTextLabel
@onready var _advanceHint = $AdvanceHint
@onready var _animationPlayer = $AnimationPlayer

func setText(s):
	print("SpeechBubble ", name, " | Set Text: ", s)
	_richTextLabel.text = s
	visible = true

func end():
	visible = false

func showAdvance():
	_animationPlayer.play(&"ShowAdvance")

func hideAdvance():
	_animationPlayer.play(&"HideAdvance")
