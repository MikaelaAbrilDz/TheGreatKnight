extends Node




func ChangeMusicToKnight():
	$GamerMusic.stop()
	$KnightMusic.play()
func ChangeMusicToGamer():
	$KnightMusic.stop()
	$GamerMusic.play()


func _on_knight_mover_pressed() -> void:
	ChangeMusicToGamer()


func _on_gamer_mover_pressed() -> void:
	ChangeMusicToKnight()
