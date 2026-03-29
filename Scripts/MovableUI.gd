extends Control

@onready var desiredPos : Vector2 = position
var movementSpeed : float = 5

func Move(newPosition : Vector2):
	desiredPos = newPosition

func _process(delta: float) -> void:
	if position != desiredPos:
		position = position.lerp(desiredPos, movementSpeed * delta)
