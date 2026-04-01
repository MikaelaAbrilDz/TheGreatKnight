extends ActionButton

func _ready() -> void:
	text = $RichTextLabel


func _on_mouse_entered() -> void:
	isHovered = true
	if not disabled: sfxPlayer.PlaySfx(sfxPlayer.sfx.KnightEnterButton)
	MoveText()

func _on_mouse_exited() -> void:
	isHovered = false
	MoveText()

func _on_button_down() -> void:
	isPressed = true
	sfxPlayer.PlaySfx(sfxPlayer.sfx.KnightPressButton)
	MoveText()

func _on_button_up() -> void:
	isPressed = false
	MoveText()
