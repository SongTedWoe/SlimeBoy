extends PlayerState

func enter(_msg:= {}):
	player.rotateToWallRight()
	state_machine.transition_to("Idle")
