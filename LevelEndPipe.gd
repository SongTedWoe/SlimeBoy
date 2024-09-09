extends Interactable
class_name LevelEndPipe

func _ready():
	if highLightNode:
		highLightNode.visible = false

func getInteraction() -> Interaction:
	return Interaction.new(type, self, {"start": self.global_position})
