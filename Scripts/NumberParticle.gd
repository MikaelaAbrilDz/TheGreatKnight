extends RichTextLabel

@export var duration : float = 0.5
@export var speed : float = 150
var counter : float
@onready var originalPos : Vector2 = position

func _process(delta: float) -> void:
	position.y -= delta * speed
	counter += delta
	modulate.a += delta * 5
	if counter > duration:
		visible = false

func _on_visibility_changed() -> void:
		ResetStuff()

func ResetStuff():
		counter = 0
		modulate.a = 0
		position = originalPos
