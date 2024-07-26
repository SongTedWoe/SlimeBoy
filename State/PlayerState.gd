class_name PlayerState
extends State

var player: Player

func _ready():
	await(owner.ready)
	player = owner as Player
	assert(player != null)

func _sliperyCheck():
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		if collision.get_collider().is_in_group("Slippery"):
			print("is slippery ", collision.get_collider().name)
		print("I collided with ", collision.get_collider().name)
	pass
