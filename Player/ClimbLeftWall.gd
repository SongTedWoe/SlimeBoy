extends PlayerState

func enter(_msg:= {}):
	player.rotateToWallLeft()
	state_machine.transition_to("Idle")
