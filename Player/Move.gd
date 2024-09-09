#Move.gd
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
	print("in state Move")
	down = player.down
	leftDirection = player.leftDirection
	rightDirection = player.rightDirection
	climbDirection = player.climbDirection
	crouchDirection = player.crouchDirection
	
	no_physics_update_yet = true
	animation_started = false
	
	player.showInteractionDisplay()
	
	#initiate_walk = false
	#if _msg.has("walkStart"):
	#	initiate_walk = _msg["walkStart"]
		
func exit():
	player.animation_tree.set("parameters/Walking Transition/transition_request", "walk start")
	player.hideInteractionDisplay()

func update(delta:float):
	if no_physics_update_yet:
		return
	
	if Input.is_action_pressed(climbDirection):
		if player.CanClimb():
			state_machine.transition_to("WallChange")
			return
		elif down != Vector2.DOWN:
			transitionToAir()
			return
	
	if down == Vector2.DOWN or down == Vector2.UP:
		if is_equal_approx(player.velocity.x, 0):
			state_machine.transition_to("Idle")
			return
	else:
		if is_equal_approx(player.velocity.y, 0):
			state_machine.transition_to("Idle")
			return
	
	if not animation_started:
		player.animation_tree.set("parameters/moving/blend_amount", 1)
		#if initiate_walk : player.nextAnimation("walk start")
		#player.nextAnimation("walk")
		animation_started = true

func physics_update(delta: float):
	#Slippery Ground Check
	var col = player.move_and_collide(player.down, true)
	if col != null:
		if col.get_collider().is_in_group(&"Slippery"):
			transitionToAir()
			
	# check if floor is missing
	var downPressed = Input.is_action_pressed(crouchDirection)
	player.velocity += player.down * player.ground_gravity * delta * (10 if downPressed else 1)
	player.velocity = player.velocity.limit_length(player.MAX_FALL_SPEED)
	
	var direction = Input.get_axis(leftDirection, rightDirection)
	
	if down == Vector2.DOWN or down == Vector2.UP:
		
		if direction:
			player.velocity.x = direction * player.SPEED
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
		
		player.move_and_slide()
		
		if player.velocity.x > 0 or direction > 0:
			player.facingRight = true
		elif player.velocity.x < 0 or direction < 0: 
			player.facingRight = false
	else:
		
		if direction:
			player.velocity.y = -direction * player.SPEED
		else:
			player.velocity.y = move_toward(player.velocity.y, 0, player.SPEED)
		
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
	state_machine.transition_to("Air")
