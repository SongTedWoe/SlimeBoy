extends PlayerState

var AnimName = &"pickup"
var AnimName_left = &"pickup_left"

func enter(_msg:={}):
	if _msg.has("start"):
		player.global_position = _msg.start
	player.animation_tree.set("parameters/Pickup One Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	player.animation_tree.animation_finished.connect(onAnimationFinished)

func exit(_msg:={}):
	player.animation_tree.animation_finished.disconnect(onAnimationFinished)

func onAnimationFinished(name):
	if name == AnimName or name == AnimName_left:
		state_machine.transition_to("Idle")
