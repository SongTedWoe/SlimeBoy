@tool
extends Node2D

@export var tog:bool:
	set(value):
		test()

# This is the variable we want to interrogate
@export var averylongnamesoicanseeit:String 
@export var AveryLongMarkerSoIcanseeit:Marker2D 

func test():
	print("Hallo")
	print( get_script().get_script_property_list() )
