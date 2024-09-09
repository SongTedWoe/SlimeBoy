extends PlayerState

const Anim_name = &"fall start"
const Anim_name_left = &"fall start_left"

var animation_finished := false

func enter(_msg:= {}):
	print("in state Air")
	player.rotatePhysicsToGround()
	if not _msg.has("air"):
		player.animation_tree.set("parameters/Falling Transition/transition_request", "fall start")
	player.animation_tree.set("parameters/Grounded/blend_amount", 1)
	player.animation_tree.set("parameters/Falling/blend_amount", 0)
	player.animation_tree.animation_finished.connect(onAnimationFinished)
	animation_finished = false
	
	player.velocity = player.down * -1 
	player.move_and_slide()
	
	player.SpringDetect.area_entered.connect(onSpringEnter)

func exit():
	player.animation_tree.set("parameters/Exit Spring One Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	player.animation_tree.animation_finished.disconnect(onAnimationFinished)
	
	player.SpringDetect.area_entered.disconnect(onSpringEnter)

func physics_update(delta: float):
	player.velocity.y = move_toward(player.velocity.y, player.MAX_FALL_SPEED, player.fall_gravity * delta)
	#print(player.velocity, delta, player.position, player.fall_gravity*delta, player.fall_gravity)
	
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
	
	if player.is_on_floor():
		animationCheckOutIdle()
		state_machine.transition_to("Idle")
		return
	
	player.updateFacing()

func onAnimationFinished(anim1:StringName):
	if anim1 == Anim_name or anim1 == Anim_name_left:
		animation_finished = true

func onAnimationChanged(anim1:StringName, anim2: StringName):
	if anim1 == Anim_name or anim1 == Anim_name_left:
		animation_finished = true

func onSpringEnter(body):
	if body is Spring:
		body.playSpringAnimation()
		player.currentSpringData = body.getSpringData()
		animationCheckoutSpringStart()
		state_machine.transition_to("SpringStart")
		#player.velocity = - player.down * body.Strength
		
func animationCheckOutIdle():
	if animation_finished:
		player.animation_tree.set("parameters/Landing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	player.animation_tree.set("parameters/Grounded/blend_amount", 0)

func animationCheckoutSpringStart():
	pass
