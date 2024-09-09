extends Node2D
class_name Door

@export var startOpen := false

@onready var animationPlayer = $AnimationPlayer

var open = false

var Keys : Array[Keyhole] = []

func _ready():
	if startOpen:
		animationPlayer.play("startOpen")
		open = true
	else:
		animationPlayer.play("startClosed")
		open = false

func Open(k):
	if not Keys.has(k):
		Keys.append(k)
	
	var anyKey = Keys.size() > 0
	
	if anyKey:
		if not open:
			animationPlayer.play("Open")
			open = true

func Close(k):
	if Keys.has(k):
		Keys.erase(k)
	
	var anyKey = Keys.size() > 0
	
	if not anyKey:
		if open:
			animationPlayer.play("Close")
			open = false
