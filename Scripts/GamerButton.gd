extends ActionButton

func _ready() -> void:
	text = $RichTextLabel



func _on_mouse_entered() -> void:
	isHovered = true
	sfxPlayer.PlaySfx(sfxPlayer.sfx.GamerEnterButton)
	MoveText()

func _on_mouse_exited() -> void:
	isHovered = false
	MoveText()

func _on_button_down() -> void:
	isPressed = true
	sfxPlayer.PlaySfx(sfxPlayer.sfx.GamerPressButton)
	MoveText()

func _on_button_up() -> void:
	isPressed = false
	MoveText()
