extends Area2D

@export var index : int = 0

@onready var pickupSecretSound = $PickupSecretSound
@onready var Visuals = [
	$Sway/Visual1, 
	$Sway/Visual2, 
	$Sway/Visual3, 
	$Sway/Visual4
]


var collected := false

func _ready():
	body_entered.connect(getSecret)
	
	for v in Visuals:
		v.visible = false
	
	Visuals[index].visible = true

func _exit_tree():
	if not collected:
		body_entered.disconnect(getSecret)

func getSecret(body):
	GameManager.getSecret(index)
	body_entered.disconnect(getSecret)
	collected = true
	
	hide()
	
	pickupSecretSound.play()
	await  pickupSecretSound.finished
	queue_free()
