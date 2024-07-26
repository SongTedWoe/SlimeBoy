extends PlayerState

const Anim_Name := &"climb"
const Anim_Name_left := &"climb_left"

func enter(_msg:={}):
	print("in state WallChange")
	player.animation_tree.set("parameters/Landing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	player.goToWall()
	player.velocity = Vector2.ZERO
	player.animation_tree.set("parameters/Climb One Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	#player.clearAnimation()
	#player.playAnimation("climb")
	player.animation_tree.animation_finished.connect(onAnimationFinished)
	#player.animation_player.animation_finished.connect(onAnimationFinished)

func exit():
	print("exit state WallChange")
	player.animation_tree.set("parameters/Climb One Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	player.animation_tree.animation_finished.disconnect(onAnimationFinished)
	#player.animation_player.animation_finished.disconnect(onAnimationFinished)

func physics_update(delta:float):
	player.velocity = player.down * delta
	player.move_and_slide()

func onAnimationFinished(anim: StringName):
	if anim == Anim_Name or anim == Anim_Name_left:
		# if player on Ceiling or Ground -> facingRight: transition To Wall right | else transition To Wall left
		# if player on Wall -> facingRight: transition To Ceiling | else transition To Ground
		if player.down == Vector2.DOWN or player.down == Vector2.UP:
			if player.facingRight:
				player.rotatePhysicsToWallRight()
			else:
				player.rotatePhysicsToWallLeft()
		else:
			if player.facingRight:
				player.rotatePhysicsToCeiling()
			else:	
				player.rotatePhysicsToGround()
		
		state_machine.transition_to("Idle")
