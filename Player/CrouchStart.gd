extends PlayerState

var AnimName = &"crouch start"
var AnimName_left = &"crouch start_left"

func enter(_msg := {}):
	print ("In state Crouch Start")
	player.animation_tree.set("parameters/crouching/blend_amount", true)
	player.animation_tree.set("parameters/enter Crouch Transition/transition_request", "crouch start")
	player.animation_tree.set("parameters/Landing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	player.animation_tree.animation_finished.connect(onAnimationFinished)

func exit():
	player.animation_tree.animation_finished.disconnect(onAnimationFinished)

func onAnimationFinished(name: StringName):
	if name == AnimName or name == AnimName_left:
		
		state_machine.transition_to("CrouchIdle")

func transitionToAir():
	player.animation_tree.set("parameters/FallingFrom/blend_position", player.down)
	player.animation_tree.set("parameters/crouching/blend_amount", false)
	state_machine.transition_to("Air")
