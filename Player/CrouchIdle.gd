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

func update(delta: float):
	if not Input.is_action_pressed(crouchDirection):
		state_machine.transition_to("Uncrouch")
		return
		
	if Input.get_axis(leftDirection, rightDirection) != 0:
		state_machine.transition_to("CrouchWalk")
		return

func physics_update(delta: float):
	player.velocity += player.down * player.gravity * delta
	player.move_and_slide()
	
	if not player.is_on_Ground():
		transitionToAir()
		return

func transitionToAir():
	player.animation_tree.set("parameters/FallingFrom/blend_position", down)
	player.animation_tree.set("parameters/crouching/blend_amount", false)
	state_machine.transition_to("Air")
