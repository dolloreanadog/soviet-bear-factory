extends Control
class_name FactoryPanel

@onready var factory_panel: TextureButton = $FactoryPanel
@onready var name_label: Label = $NameLabel
@onready var quota_label: Label = $QuotaLabel
@onready var panel: Panel = $Panel

@onready var boost_button: Button = $Panel/VBoxContainer/BoostButton
@onready var investigate_button: Button = $Panel/VBoxContainer/InvestigateButton
@onready var execute_button: Button = $Panel/VBoxContainer/ExecuteButton

enum FactoryStatus {GOOD, BAD, DEAD}
var current_status: FactoryStatus = FactoryStatus.GOOD

var factory_id: int

@export var boost_cost: int = 100
@export var investigate_cost: int = 300

signal boost_pressed(id: int)
signal investigate_pressed(id: int)
signal execute_pressed(id: int)

func choose_status(status: FactoryStatus) -> void:
	match status:
		FactoryStatus.GOOD:
			factory_panel.self_modulate = Color.GREEN
			factory_panel.disabled = false
		FactoryStatus.BAD:
			factory_panel.self_modulate = Color.RED
			factory_panel.disabled = false
		FactoryStatus.DEAD:
			factory_panel.self_modulate = Color.BLACK
			factory_panel.disabled = true
			panel.hide()
		_:
			pass

func can_afford(amount: int) -> bool:
	var main_game: MainGame = get_tree().get_first_node_in_group("MainGame")
	var stalin: Player = main_game.get_player_as_player(main_game.stalin_player_id)
	
	if stalin.ruble >= amount:
		return true
	else:
		return false

func _on_factory_panel_pressed() -> void:
	panel.show()
	if can_afford(boost_cost):
		boost_button.disabled = false
	else:
		boost_button.disabled = true
	
	if can_afford(investigate_cost):
		investigate_button.disabled = false
	else:
		investigate_button.disabled = true

func close() -> void:
	choose_status(FactoryStatus.DEAD)

func _on_done_button_pressed() -> void:
	panel.hide()


func _on_boost_button_pressed() -> void:
	panel.hide()
	boost_pressed.emit(factory_id)


func _on_investigate_button_pressed() -> void:
	panel.hide()
	investigate_pressed.emit(factory_id)


func _on_execute_button_pressed() -> void:
	panel.hide()
	execute_pressed.emit(factory_id)
	close()
