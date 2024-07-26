extends PlayerState

const Anim_name = &"fall start"
const Anim_name_left = &"fall start_left"

var animation_finished := false

func enter(_msg:= {}):
	print("in state Air")
	player.rotatePhysicsToGround()
	player.animation_tree.set("parameters/Falling Transition/transition_request", "fall start")
	player.animation_tree.set("parameters/Grounded/blend_amount", 1)
	player.animation_tree.animation_finished.connect(onAnimationFinished)
	#player.clearAnimation()
	#player.playAnimation("fall start")
	#player.nextAnimation("fall")
	animation_finished = false
	#player.animation_player.animation_changed.connect(onAnimationChanged)
	
	player.velocity = player.down * -1 * player.SPEED
	player.move_and_slide()
	
	player.SpringDetect.area_entered.connect(onSpringEnter)

func exit():
	#player.animation_player.animation_changed.disconnect(onAnimationChanged)
	
	if animation_finished:
		player.animation_tree.set("parameters/Landing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		#player.clearAnimation()
		#player.playAnimation("land")
		#player.animation_player.advance(0)
	player.animation_tree.set("parameters/Grounded/blend_amount", 0)
	player.animation_tree.animation_finished.disconnect(onAnimationFinished)
	
	player.SpringDetect.area_entered.disconnect(onSpringEnter)

func physics_update(delta: float):
	player.velocity.y = move_toward(player.velocity.y, player.MAX_FALL_SPEED, player.gravity * delta)
	
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
		player.velocity = - player.down * body.Strength
