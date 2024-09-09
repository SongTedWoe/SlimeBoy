extends Interactable
class_name Pipe

@export var PipeGroup : int
@export var PipeOrder : int = -1

var ID : int

func _ready():
	if highLightNode:
		highLightNode.visible = false
	type = Interaction.InteractionType.PIPE
	PipeManager.addPipe(self)

func _getNextLocation() -> Vector2:
	var otherPipe := PipeManager.get_Next(self) as Pipe
	if otherPipe != null:
		return otherPipe.global_position
	else:
		return global_position

func _getNextDown() ->Vector2:
	var otherPipe := PipeManager.get_Next(self) as Pipe
	if otherPipe != null:
		return otherPipe.down
	else:
		return down

func getInteraction() -> Interaction:
	return Interaction.new(type, self, {"start":self.global_position ,"target": self._getNextLocation(), "down":self._getNextDown()})
