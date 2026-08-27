extends Panel
class_name TextChatPanel

@onready var text_line_edit: LineEdit = $TextLineEdit
@onready var submit_button: Button = $SubmitButton
@onready var text_chat_label: RichTextLabel = $TextChatLabel

signal text_submitted(text: String, player_name: String)

@rpc("any_peer", "call_local", "reliable")
func submit_text(text: String, player_name: String) -> void:
	for text_chat: TextChatPanel in get_tree().get_nodes_in_group("TextChat"):
		text_chat.text_chat_label.text += "%s: %s\n" % [player_name, text]


func _on_submit_button_pressed() -> void:
	text_submitted.emit(text_line_edit.text, Global.player_name)
	text_line_edit.clear()


func _on_text_line_edit_text_submitted(new_text: String) -> void:
	submit_text.rpc(new_text, Global.player_name)
	text_line_edit.clear()


func _sync_chat(text: String, player_name: String) -> void:
	submit_text.rpc(text, player_name)
