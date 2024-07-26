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
	#player.nextAnimation("idle")
	down = player.down
	leftDirection = player.leftDirection
	rightDirection = player.rightDirection
	climbDirection = player.climbDirection
	crouchDirection = player.crouchDirection
	
	player.velocity = Vector2.ZERO
	
	no_physics_update_yet = true
	
	#print("down: " + str(down) + " | right: " + str(rightDirection) + " | leftDirection: " + str(leftDirection) + " | climbDirection: " + str(climbDirection))

func exit():
	player.animation_tree.set("parameters/Idle Restart/transition_request", "idle_enter")

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
		state_machine.transition_to("CrouchStart")
		return

func physics_update(delta: float):
	player.velocity += player.down * player.gravity * delta
	player.move_and_slide()
	
	if not player.is_on_Ground():
		transitionToAir()
		return
	
	
	
	no_physics_update_yet = false

func transitionToAir():
	player.animation_tree.set("parameters/FallingFrom/blend_position", down)
	state_machine.transition_to("Air")
