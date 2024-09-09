extends Object
class_name Interaction

enum InteractionType{
	LEVEL_END,
	PIPE,
	PICKUP
}

var type : InteractionType
var origin : Object
var data : Dictionary
func _init(t:InteractionType, o:Object, d:Dictionary = {}):
	type = t
	origin = o
	data = d
