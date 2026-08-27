extends Node2D
class_name MainMenu

@onready var host_button: Button = $Main/VBoxContainer/HostButton
@onready var player_line_edit: LineEdit = $Main/VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PlayerLineEdit
@onready var ip_line_edit: LineEdit = $Main/VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/IPLineEdit
@onready var settings_button: Button = $Main/VBoxContainer/SettingsButton
@onready var exit_button: Button = $Main/VBoxContainer/ExitButton


func _on_host_button_pressed() -> void:
	NetworkManager.create_server()
	await get_tree().create_timer(0.5).timeout
	Global.go_to_game()
	queue_free()


func _on_join_button_pressed() -> void:
	Global.go_to_game()
	#await get_tree().create_timer(0.5).timeout
	NetworkManager.join_server(ip_line_edit.text)
	queue_free()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_change_button_pressed() -> void:
	Global.player_name = player_line_edit.text
