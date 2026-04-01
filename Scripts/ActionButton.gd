extends TextureButton
class_name ActionButton

var isPressed : bool
var isHovered : bool

var text : RichTextLabel
@export var sfxPlayer : SfxManager

func _ready() -> void:
	text = $RichTextLabel

func MoveText():
	if isHovered:
		text.position.y = -35
	if isPressed:
		text.position.y = 0
	if not isHovered:
		text.position.y = -25
	
	if disabled : text.position.y = -25
