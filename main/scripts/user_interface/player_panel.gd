extends Panel
class_name PlayerPanel

@onready var name_label: Label = $NameLabel
@onready var kick_button: Button = $KickButton
var owner_id: int = -1

func show_hide_kick() -> void:
	if NetworkManager.is_host:
		kick_button.show()
	else:
		kick_button.hide()
	
	if owner_id == 1:
		kick_button.hide()

@rpc("any_peer","call_local", "reliable")
func kick_person(id: int) -> void:
	multiplayer.multiplayer_peer.disconnect_peer(id)

func _on_kick_button_pressed() -> void:
	if NetworkManager.is_host:
		kick_person.rpc(owner_id)
	
	kick_button.disabled = true
