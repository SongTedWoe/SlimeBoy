extends PlayerState

func enter(_msg := {}):
	player.animation_tree.set("parameters/Death OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	#player.playAnimation("death")

func update(delta:float):
	if Input.is_key_pressed(KEY_SPACE):
		GameManager.reset()

func physics_update(delta:float):
	player.velocity = Vector2.DOWN
	
	player.move_and_slide()
