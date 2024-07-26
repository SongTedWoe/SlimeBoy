extends PlayerState

func enter(_msg:= {}):
	player.rotateToCeiling()
	state_machine.transition_to("Idle")
