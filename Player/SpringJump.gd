extends PlayerState

const COOLDOWN_TIME = 0.2

var switch_time : float
var time : float
var ending : bool 

var leaning_rad : float

func enter(_msg := {}):
	print("in state SpringJump")
	switch_time = player.currentSpringData.jump_duration - COOLDOWN_TIME
	time = 0
	ending = false
	leaning_rad = deg_to_rad(player.rise_leaning_angle)

func physics_update(delta: float):
	time += delta
	if time >= switch_time and not ending:
		player.animation_tree.set("parameters/Exit Spring One Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		ending = true
	
	player.velocity.y = move_toward(player.velocity.y, player.MAX_FALL_SPEED, player.rise_gravity * delta)
	
	var direction = Input.get_axis("left", "right")
	
	if direction:
		player.velocity.x = direction * player.SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	
	player.move_and_slide() 
	
	if player.velocity.x > 0:
		player.facingRight = true
	elif player.velocity.x < 0:
		player.facingRight = false
	
	if player.velocity.y >= 0:
		player.rotation = 0
		state_machine.transition_to("SpringEnd")
		return
	
	if direction > 0:
		player.rotation = leaning_rad
	elif direction < 0:
		player.rotation = - leaning_rad
	else:
		player.rotation = 0

	player.updateFacing()
