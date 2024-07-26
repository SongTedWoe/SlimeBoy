extends AnimationPlayer

@export var AnimationName : String

func RunAnimation():
	play(AnimationName)


func _on_area_2d_body_entered(body):
	RunAnimation()
