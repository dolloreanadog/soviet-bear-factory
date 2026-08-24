extends Control
class_name FactoryOwnerPanel

@onready var name_label: Label = $NameLabel
@onready var quota_label: Label = $QuotaLabel
@onready var option_panel: Panel = $OptionPanel

# This should be player's network id
var owner_id: int

signal info_pressed(id: int)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("been pressed")
			option_panel.show()


func _on_done_button_pressed() -> void:
	option_panel.hide()


func _on_info_button_pressed() -> void:
	info_pressed.emit(owner_id)
	# Then move into the more info area


func _on_boost_button_pressed() -> void:
	# Check if stalin has enough
	# Then give points to the other player
	pass # Replace with function body.


func _on_investigate_button_pressed() -> void:
	# Check if stalin has enough
	# Then we can have paper printed from top of the screen
	pass # Replace with function body.


func _on_execute_button_pressed() -> void:
	pass # Replace with function body.
