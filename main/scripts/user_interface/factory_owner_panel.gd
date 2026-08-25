extends Control
class_name FactoryOwnerPanel

@onready var name_label: Label = $NameLabel
@onready var quota_label: Label = $QuotaLabel
@onready var option_panel: Panel = $OptionPanel

@onready var boost_button: Button = $OptionPanel/VBoxContainer/BoostButton
@onready var investigate_button: Button = $OptionPanel/VBoxContainer/InvestigateButton
@onready var execute_button: Button = $OptionPanel/VBoxContainer/ExecuteButton

@export var ability_cooldown: float = 2

# This should be player's network id
var owner_id: int = -1

signal info_pressed(id: int)
signal investigate_pressed(id: int)
signal boost_pressed(id: int)
signal execute_pressed(id: int)

func buttons_cooldown() -> void:
	boost_button.disabled = true
	investigate_button.disabled = true
	execute_button.disabled = true
	await get_tree().create_timer(ability_cooldown).timeout
	boost_button.disabled = false
	investigate_button.disabled = false
	execute_button.disabled = false


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
	boost_pressed.emit(owner_id)


func _on_investigate_button_pressed() -> void:
	# Check if stalin has enough
	# Then we can have paper printed from top of the screen
	investigate_pressed.emit(owner_id)


func _on_execute_button_pressed() -> void:
	execute_pressed.emit(owner_id)
	
