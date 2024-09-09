extends Area2D
class_name Keyhole

signal KeyArrived
signal KeyLeft

@export var startOccupied := false
@export var occupyingKey : Area2D

@export var Keys : Array[Area2D]

@export var Doors : Array[Door]

var occupied := false

func _ready():
	if startOccupied and occupyingKey:
		occupied = true
		for d in Doors:
			d.Open(self)
	
	area_entered.connect(onPossibleKeyConnect)
	area_exited.connect(onPossibleKeyLeave)

func _exit_tree():
	area_entered.disconnect(onPossibleKeyConnect)
	area_exited.disconnect(onPossibleKeyLeave)

func onPossibleKeyConnect(body):
	if not occupied:
		if Keys.has(body):
			occupied = true
			occupyingKey = body
			KeyArrived.emit()
			for d in Doors:
				d.Open(self)

func onPossibleKeyLeave(body):
	if occupied:
		if Keys.has(body):
			occupied = false
			occupyingKey = null
			KeyLeft.emit()
			for d in Doors:
				d.Close(self)
