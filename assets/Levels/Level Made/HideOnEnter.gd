extends Area2D

@export var objectsToHide : Array[CanvasItem]

@onready var disappearSound = $DisappearSound

@onready var connected = true

func _ready():
	body_entered.connect(hideObjects)

func _exit_tree():
	if connected:
		body_entered.disconnect(hideObjects)

func hideObjects(body):
	var tween = create_tween()
	tween.set_parallel()
	for o in objectsToHide:
		tween.tween_property(o,"modulate", Color(1,1,1,0), disappearSound.stream.get_length())
	tween.set_parallel(false)
	tween.tween_callback(makeInvisible)
	disappearSound.play()
	
	body_entered.disconnect(hideObjects)
	connected = false

func makeInvisible():
	for o in objectsToHide:
		o.visible = false
