extends Resource
class_name DialogAction

enum Type {
	TEXT,
	WAIT,
	ANIMATION
}

@export var type: Type = Type.TEXT
@export var display: DialogManager.Display = DialogManager.Display.None
@export_multiline var text: String = "Please change me"
@export var time: float = 8
@export var hideOtherDisplays := true
