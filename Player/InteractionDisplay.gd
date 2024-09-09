extends Node2D

@onready var player := $".." as Player

var show = false
var show_all:
	get: 
		return show
	set(value):
		show = value
		update_display()

var pipe_detected = false
var pickup_detected = false

func _ready():
	call_deferred(&"update_display")

func pipe_detect_enter(body):
	call_deferred(&"update_display")

func pipe_detect_exit(body):
	call_deferred(&"update_display")

func pickup_detect_enter(body):
	call_deferred(&"update_display")

func pickup_detect_exit(body):
	call_deferred(&"update_display")

func update_display():
	visible = show and player.hasInteraction()
