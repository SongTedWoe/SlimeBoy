#Idle.gd
extends PlayerState

var facing : int

var down := Vector2.DOWN
var leftDirection := &"left"
var rightDirection := &"right"
var climbDirection := &"up"
var crouchDirection := &"down"

var no_physics_update_yet = true

func enter(_msg:= {}): 
	player.animation_tree.set("parameters/moving/blend_amount", 0)
	player.animation_tree.set("parameters/Walking Transition/transition_request", "walk start")
	print("in state Idle | DOWN = " + str(down))
	down = player.down
	leftDirection = player.leftDirection
	rightDirection = player.rightDirection
	climbDirection = player.climbDirection
	crouchDirection = player.crouchDirection
	
	player.velocity = Vector2.ZERO
	
	player.showInteractionDisplay()
	
	no_physics_update_yet = true

func exit():
	player.animation_tree.set("parameters/Idle Restart/transition_request", "idle_enter")
	player.hideInteractionDisplay()

func update(delta:float):
	if no_physics_update_yet: return
	
	if Input.get_axis(leftDirection, rightDirection) != 0:
		state_machine.transition_to("Move", { walkStart = true })
		return
	
	if Input.is_action_pressed(climbDirection):
		if player.CanClimb():
			state_machine.transition_to("WallChange")
			return
		elif down != Vector2.DOWN:
			transitionToAir()
			return
	
	if Input.is_action_pressed(crouchDirection):
		if player.hasPickup:
			player.dropPickup()
		if player.hasInteraction():
			player.Interact()
			return
		state_machine.transition_to("CrouchStart")
		return

func physics_update(delta: float):
	# Ground check for Slipery Ground:
	# because it is only checks for floor, any other checks is not necessary 
	# ->
	# 1. move only ground direction and check if hitting slipery ground
	# 2. move sideways afterwards for other things
	#
	# alternatively can use move_and_collide to figure out any floor impressions
	
	var col = player.move_and_collide(player.down, true)
	if col != null:
		if col.get_collider().is_in_group(&"Slippery"):
			transitionToAir()
	
	player.velocity += player.down * player.ground_gravity * delta
	player.move_and_slide()
	
	if not player.is_on_Ground():
		transitionToAir()
		return
	
	no_physics_update_yet = false

func transitionToAir():
	player.animation_tree.set("parameters/FallingFrom/blend_position", down)
	state_machine.transition_to("Air")
