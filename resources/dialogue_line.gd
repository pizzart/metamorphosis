class_name DialogueLine
extends Resource

enum Speaker {
	You,
	Other,
}

@export_multiline var line = ""
@export var speaker = Speaker.You
