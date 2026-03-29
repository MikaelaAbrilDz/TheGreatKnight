extends Node2D
class_name TransitionManager

@onready var knightMover : TextureButton = $Knight/TitleHolder/Mover


func FirstTransition():
	knightMover.visible = true
