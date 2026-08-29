extends Control
class_name TargetPanel

var target_id: int

@onready var name_label: Label = $NameLabel
@onready var status_label: Label = $StatusLabel

signal target_selected(id: int)

func check_quota_status() -> void:
	var main_game: MainGame = get_tree().get_first_node_in_group("MainGame")
	
	var player: Player = main_game.get_player_as_player(target_id)
	
	if player.factory_manager.is_meeting_quota():
		status_label.text = "Meets Quota"
		status_label.self_modulate = Color.GREEN
	else:
		status_label.text = "Doesn't Meet Quota"
		status_label.self_modulate = Color.RED

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("been pressed")
			target_selected.emit(target_id)
