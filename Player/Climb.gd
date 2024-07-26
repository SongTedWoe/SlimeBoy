extends PlayerState

var lock : bool
var strain: float
var wallObject: Node2D

func enter(_msg:={}):
	strain = 0;

func exit():
	player.animation_tree.set("parameters/Climb One Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

func physics_update(delta: float):
	var input = Input.get_vector(&"left", &"right", &"down", &"up")
	
	var gravity = player.down
	
	if strain > player.CLIMB_STRENGTH:
		state_machine.transition_to("Air")
	
	var fallFactor = 1 if player.facingRight else -1
	player.velocity.x = move_toward(player.velocity.x, player.MAX_FALL_SPEED * fallFactor, player.gravity * delta)
	player.velocity.y = input * player.SPEED
	
	print(player.velocity)
	
	player.move_and_slide()
	
	if not player.is_on_wall():
		state_machine.transition_to("Air")
	
