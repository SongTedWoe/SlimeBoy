extends PlayerState

func enter(_msg := {}):
	state_machine.transition_to("Air", {"air": true})
