extends PlayerState

var AnimName := &"level exit"
var AnimName_left := &"level exit_left"

func enter(_msg := {}):
	print("in state Level End")
	if _msg.has("start"):
		player.global_position = _msg.start
	
	player.animation_tree.set("parameters/Level Exit One Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	player.animation_tree.animation_finished.connect(OnAnimationFinished)

func exit():
	player.animation_tree.animation_finished.disconnect(OnAnimationFinished)
	player.active = false

func OnAnimationFinished(name):
	if name == AnimName or name == AnimName_left:
		GameManager.endLevel()
		state_machine.transition_to("Idle")
