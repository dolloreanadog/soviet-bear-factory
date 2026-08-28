extends Node2D
class_name FactoryView

@onready var factory_camera: Camera2D = $FactoryCamera
@onready var bottom_ui_panel: BottomUIPanel = $FactoryCamera/BottomUIPanel

@onready var approval_doc: ApprovalDoc = $ApprovalDoc
@onready var target_selection_doc: TextureRect = $TargetSelectionDoc

@onready var production_button: Button = $VBoxContainer/ProductionButton
@onready var forge_button: Button = $VBoxContainer/ForgeButton
@onready var security_button: Button = $VBoxContainer/SecurityButton
@onready var sabatoge_button: Button = $VBoxContainer/SabatogeButton
@onready var steal_button: Button = $VBoxContainer/StealButton


signal action_selected(action: FactoryManager.ActionSelection)
signal decision_approved()
signal target_selected(id: int)

func _on_production_button_pressed() -> void:
	action_selected.emit(FactoryManager.ActionSelection.PRODUCE)


func _on_forge_button_pressed() -> void:
	action_selected.emit(FactoryManager.ActionSelection.FORGE)


func _on_security_button_pressed() -> void:
	action_selected.emit(FactoryManager.ActionSelection.SECURITY)


func _on_sabatoge_button_pressed() -> void:
	action_selected.emit(FactoryManager.ActionSelection.SABATOGE)


func _on_steal_button_pressed() -> void:
	action_selected.emit(FactoryManager.ActionSelection.STEAL)

func open_approval(title: String) -> void:
	approval_doc.yes_texture.hide()
	approval_doc.no_texture.hide()
	approval_doc.show()
	approval_doc.title_label.text = title

func _open_target_selection(title: String) -> void:
	pass
