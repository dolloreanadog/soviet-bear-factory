extends TextureRect
class_name ApprovalDoc

@onready var title_label: Label = $TitleLabel
@onready var accept_button: PanelContainer = $AcceptButton
@onready var decline_button: PanelContainer = $DeclineButton
@onready var blocker: Control = $Blocker

@onready var yes_texture: Sprite2D = $YesTexture
@onready var no_texture: Sprite2D = $NoTexture

signal accept_button_pressed()
signal decline_button_pressed()


func _on_accept_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("been pressed")
			accept_button_pressed.emit()
			yes_texture.show()
			blocker.show()
			await get_tree().create_timer(0.5).timeout
			blocker.hide()
			hide()


func _on_decline_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("been pressed")
			decline_button_pressed.emit()
			no_texture.show()
			blocker.show()
			await get_tree().create_timer(0.5).timeout
			blocker.hide()
			hide()
