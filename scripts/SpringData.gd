@tool
extends Resource
class_name SpringData

enum SpringDataType {
	Jump,
	Direction,
	LocationVector,
	LocationMarker
}

@export var type : SpringDataType:
	set(value):
		type = value
		notify_property_list_changed()

var direction : Vector2
var height : float = 48
var locationVector : Vector2
var locationMarker : Marker2D
var jump_startup_duration : float = 0
var jump_startup_hide_Player : bool = false
var jump_duration : float = 1


func _get_property_list():
	if Engine.is_editor_hint():
		var properties = []
		match type:
			SpringDataType.Direction:
				properties.append({
					"name": "direction",
					"type": TYPE_VECTOR2,
					"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
					"hint": PROPERTY_HINT_NONE
				})
				
			SpringDataType.Jump:
				properties.append({
					"name": "height",
					"type": TYPE_FLOAT,
					"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
					"hint": PROPERTY_HINT_NONE
				})
			SpringDataType.LocationVector:
				properties.append({
					"name": "locationVector",
					"type": TYPE_VECTOR2,
					"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
					"hint": PROPERTY_HINT_NONE
				})
				
			SpringDataType.LocationMarker:
				properties.append({
					"name": "locationMarker",
					"class_name": &"Marker2D",
					"type": TYPE_OBJECT,
					"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
					"hint": PROPERTY_HINT_NODE_TYPE,
					"hint_string": "Marker2D"
				})
		
		properties.append({
			"name": "jump_duration",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"hint": PROPERTY_HINT_NONE
		})
		
		properties.append({
			"name": &"startup",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP,
			# just exclude the "hint_string"
		 })
		properties.append({
			"name": "jump_startup_duration",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"hint": PROPERTY_HINT_NONE
		})
		properties.append({
			"name": "jump_startup_hide_Player",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"hint": PROPERTY_HINT_NONE
		})

		
		return properties
