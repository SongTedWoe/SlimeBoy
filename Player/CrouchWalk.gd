extends PlayerState

var down := Vector2.DOWN
var leftDirection := &"left"
var rightDirection := &"right"
var climbDirection := &"up"
var crouchDirection := &"down"
var goingRight := true

var no_physics_update_yet = true
var animation_started = false

#var initiate_walk = false

func enter(_msg:={}):
	print("in state Crouch Move")
	down = player.down
	leftDirection = player.leftDirection
	rightDirection = player.rightDirection
	climbDirection = player.climbDirection
	crouchDirection = player.crouchDirection
	
	no_physics_update_yet = true
	animation_started = false
	
	player.animation_tree.set("parameters/Crouch Walking Transition/transition_request", "crouch walk start")

func exit():
	pass

func update(delta:float):
	if no_physics_update_yet:
		return
	
	if not Input.is_action_pressed(crouchDirection):
		state_machine.transition_to("Uncrouch")
		return
	
	if down == Vector2.DOWN or down == Vector2.UP:
		if is_equal_approx(player.velocity.x, 0):
			state_machine.transition_to("CrouchIdle")
			return
	else:
		if is_equal_approx(player.velocity.y, 0):
			state_machine.transition_to("CrouchIdle")
			return
	
	if not animation_started:
		player.animation_tree.set("parameters/crouch moving/blend_amount", 1)
		animation_started = true

func physics_update(delta: float):
	# check if floor is missing
	player.velocity += player.down * player.gravity * delta
	player.velocity = player.velocity.limit_length(player.MAX_FALL_SPEED)
	
	var direction = Input.get_axis(leftDirection, rightDirection)
	
	if down == Vector2.DOWN or down == Vector2.UP:
		
		if direction:
			player.velocity.x = direction * player.CROUCH_SPEED
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, player.CROUCH_SPEED)
		
		player.move_and_slide()
		
		if player.velocity.x > 0 or direction > 0:
			player.facingRight = true
		elif player.velocity.x < 0 or direction < 0: 
			player.facingRight = false
	else:
		
		if direction:
			player.velocity.y = -direction * player.CROUCH_SPEED
		else:
			player.velocity.y = move_toward(player.velocity.y, 0, player.CROUCH_SPEED)
		
		player.move_and_slide()
		
		if player.velocity.y < 0:# or direction < 0:
			player.facingRight = true
		elif player.velocity.y > 0:# or direction > 0: 
			player.facingRight = false
	
	if not player.is_on_Ground():
		transitionToAir();
		return
	
	player.updateFacing()
	
	no_physics_update_yet = false


func transitionToAir():
	player.animation_tree.set("parameters/FallingFrom/blend_position", down)
	player.animation_tree.set("parameters/crouching/blend_amount", false)
	state_machine.transition_to("Air")
