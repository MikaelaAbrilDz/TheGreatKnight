extends TextureButton

@export var target : Vector2
@onready var cam : = $"../../../Camera2D"

func _on_pressed() -> void:
	cam.Move(target)
