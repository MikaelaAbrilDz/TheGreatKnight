extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.howDidLose == GameManager.losingMode.knightSocial:
		$RichTextLabel.text = "The knight died alone..."
		$Knight.visible = true
		$Knight/AnimationPlayer.play("Alone")
	elif GameManager.howDidLose == GameManager.losingMode.knightLife:
		$RichTextLabel.text = "The knight died from his wounds..."
		$Knight.visible = true
		$Knight/AnimationPlayer.play("Die")
	if GameManager.howDidLose == GameManager.losingMode.gamerEnergy:
		$RichTextLabel.text = "The gamer died from exhaustion..."
		$Gamer.visible = true
		$Gamer/AnimationPlayer.play("Exhaustion")
	if GameManager.howDidLose == GameManager.losingMode.gamerSocial:
		$RichTextLabel.text = "The gamer died alone..."
		$Gamer.visible = true
		$Gamer/AnimationPlayer.play("Alone")
	if GameManager.howDidLose == GameManager.losingMode.gamerHappiness:
		$RichTextLabel.text = "The gamer died from boredom..."
		$Gamer.visible = true
		$Gamer/AnimationPlayer.play("Bored")


func _onRetryPressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
