extends PlayerState

var AnimName := &"uncrouch"
var AnimName_left := &"uncrouch_left"

func enter(msg := {}):
	print("In state Uncrouch")
	player.animation_tree.set("parameters/leave crouch Transition/transition_request", "uncrouch")
	player.animation_tree.set("parameters/crouching/blend_amount", false)
	player.animation_tree.animation_finished.connect(onAnimationFinished)

func exit():
	player.animation_tree.animation_finished.disconnect(onAnimationFinished)

func onAnimationFinished(name: StringName):
	if name == AnimName or name == AnimName_left:
		state_machine.transition_to("Idle")

func transitionToAir():
	player.animation_tree.set("parameters/FallingFrom/blend_position", player.down)
	player.animation_tree.set("parameters/crouching/blend_amount", false)
	state_machine.transition_to("Air")
