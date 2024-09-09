extends PlayerState

var jumpType: Player.JumpType
var transitionImmediately := false

var g : float
var v : float

var time : float
var wait_time :float

func enter(_msg := {}):
	print("in state SpringStart")
	
	player.velocity = Vector2.ZERO
	
	resetData()
	
	evaluateSpringData(player.currentSpringData)
	
	if transitionImmediately:
		goToNextState()

func update(_delta: float):
	if time < wait_time:
		goToNextState()
	else:
		time += _delta

func goToNextState():
	player.animation_tree.set("parameters/Falling/blend_amount", 1)
	player.animation_tree.set("parameters/Spring Transition/transition_request", "spring_start")
	match jumpType:
		player.JumpType.Jump:
			player.rise_gravity = g
			player.velocity.y = v
			print(player.velocity)
			state_machine.transition_to("SpringJump")

func evaluateSpringData(data: SpringData):
	match data.type:
		SpringData.SpringDataType.Jump:
			jumpType = player.JumpType.Jump
			g = 2 * data.height / data.jump_duration / data.jump_duration
			v = - g * data.jump_duration
			print("g: ", g, " | v: ", v)
	
	if data.jump_startup_duration == 0:
		transitionImmediately = true
	else:
		wait_time = data.jump_startup_duration

func resetData():
	transitionImmediately = false
	time = 0
