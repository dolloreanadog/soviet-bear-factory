extends Control
class_name TargetContainer

var target_id: int

@onready var icon: Sprite2D = $Icon
@onready var name_label: Label = $NameLabel
@onready var quota_label: Label = $QuotaLabel

signal pressed(id: int)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("been pressed")
			pressed.emit(target_id)

func _ready() -> void:
	pass

## This will change the text whether the player met quota or not and show
func check_for_quota() -> void:
	pass
