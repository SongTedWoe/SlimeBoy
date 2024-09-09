extends PlayerState

var target
var down

var EnterAnimName = &"pipe entry"
var EnterAnimName_left = &"pipe entry_left"
var ExitAnimName = &"pipe exit"
var ExitAnimName_left = &"pipe exit_left"

func enter(_msg:= {}):
	if _msg.has("target"):
		target = _msg.target
	if _msg.has("start"):
		player.global_position = _msg.start
	if _msg.has("down"):
		down = _msg.down
	
	player.animation_tree.set("parameters/Pipe Enter One Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	player.animation_tree.animation_finished.connect(onAnimationFinished)

func exit():
	player.animation_tree.animation_finished.disconnect(onAnimationFinished)

func onAnimationFinished(name: StringName):
	if name == EnterAnimName or name == EnterAnimName_left:
		player.global_position = target
		player.animation_tree.set("parameters/Pipe Exit One Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		_rotatePlayer()
	if name == ExitAnimName or name == ExitAnimName_left:
		state_machine.transition_to("Idle")

func _rotatePlayer():
	match down:
		Vector2.DOWN:
			player.rotatePhysicsToGround()
		Vector2.UP:
			player.rotatePhysicsToCeiling()
		Vector2.RIGHT:
			player.rotatePhysicsToWallRight()
		Vector2.LEFT:
			player.rotatePhysicsToWallLeft()
