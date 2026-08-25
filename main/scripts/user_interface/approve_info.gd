extends ColorRect
class_name ApproveInfo

@onready var title_label: Label = $TitleLabel

signal yes_button_pressed()
signal no_button_pressed()

var title: String:
	set(value):
		title_label.text = value

func _yes_button_pressed() -> void:
	yes_button_pressed.emit()
	hide()

func _no_button_pressed() -> void:
	no_button_pressed.emit()
	hide()
