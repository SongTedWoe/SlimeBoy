extends PlayerState

var down := Vector2.DOWN
var leftDirection := &"left"
var rightDirection := &"right"
var climbDirection := &"up"
var crouchDirection := &"down"

var t : Tween

func enter(_msg:={}):
	print("in state Crouch Idle")
	down = player.down
	leftDirection = player.leftDirection
	rightDirection = player.rightDirection
	climbDirection = player.climbDirection
	crouchDirection = player.crouchDirection
	
	player.animation_tree.set("parameters/crouch moving/blend_amount", false)
	player.showInteractionDisplay()

func exit():
	player.hideInteractionDisplay()

func update(delta: float):
	if not Input.is_action_pressed(crouchDirection) and player.canStandUp():
		state_machine.transition_to("Uncrouch")
		return
		
	if Input.get_axis(leftDirection, rightDirection) != 0:
		state_machine.transition_to("CrouchWalk")
		return

func physics_update(delta: float):
	#Slippery Ground Check
	var col = player.move_and_collide(player.down, true)
	if col != null:
		if col.get_collider().is_in_group(&"Slippery"):
			transitionToAir()
	
	#normal Movement 
	player.velocity += player.down * player.ground_gravity * delta
	player.move_and_slide()
	
	if not player.is_on_Ground():
		transitionToAir()
		return

func transitionToAir():
	player.animation_tree.set("parameters/FallingFrom/blend_position", down)
	player.animation_tree.set("parameters/crouching/blend_amount", false)
	state_machine.transition_to("Air")
