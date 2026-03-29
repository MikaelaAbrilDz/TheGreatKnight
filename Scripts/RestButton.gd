extends ActionButton

func _ready() -> void:
	text = $RichTextLabel



func _on_mouse_entered() -> void:
	isHovered = true
	MoveText()

func _on_mouse_exited() -> void:
	isHovered = false
	MoveText()

func _on_button_down() -> void:
	isPressed = true
	MoveText()

func _on_button_up() -> void:
	isPressed = false
	MoveText()
