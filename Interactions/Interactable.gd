extends Area2D
class_name Interactable

@export var type: Interaction.InteractionType
@export var interactOnlyOnDown: bool = true
@export var down: Vector2
@export var highLightNode: Node
@export var pickupTexture : Texture
@export var physics := false
@export var physicsRay : RayCast2D
@export var fallSpeed := 100.0

var _active: bool = true
var Active: bool : 
	get:
		return _active
	set(value):
		_active = value

func enableInteractable():
	process_mode = Node.PROCESS_MODE_INHERIT

func disableInteractable():
	process_mode = Node.PROCESS_MODE_DISABLED

func showInteractable():
	visible = true

func hideInteractable():
	visible = false

func _ready():
	if highLightNode:
		highLightNode.visible = false
	if physicsRay:
		physicsRay.collide_with_bodies = true

func _physics_process(delta):
	if physics:
		if physicsRay:
			if not physicsRay.is_colliding():
				global_position += Vector2.DOWN * fallSpeed * delta
			
			if physicsRay.is_colliding():
				global_position = physicsRay.get_collision_point() + physicsRay.target_position * -1
				pass

func moveTo(pos):
	global_position = pos
	if physicsRay:
		physicsRay.force_raycast_update()

func getInteraction() -> Interaction:
	return Interaction.new(type, self)

func isInteractable(down) -> bool:
	if interactOnlyOnDown:
		return  _active and down == self.down
	return _active

func showHighLight():
	if highLightNode:
		highLightNode.visible = true

func hideHighLight():
	if highLightNode:
		highLightNode.visible = false
