extends Node2D
class_name FactoryView

@onready var approve_info: ApproveInfo = %ApproveInfo
@onready var target_select_info: TargetSelectInfo = %TargetSelectInfo
@onready var theft_manager: TheftManager = %TheftManager

@export_group("Upgrades")
@export var production_increase_amount: int = 100
@export var forging_increase_amount: int = 200
@export var sabatoge_amount = 50
@export_group("Production")
## The actual amount of production unaffected by stealing
@export var real_production: int = 200 # TODO: Probably have this emit a signal if we edit it
## How much they're actually producing real production - stolen
var actual_production: int:
	get():
		return real_production - lost_production
## How much is being currently stolen for our own production
var lost_production: int = 0:
	set(value):
		lost_production = maxi(0, lost_production)
## How much of it is stolen from others
var stolen_production: int = 0:
	set(value):
		stolen_production = maxi(0, lost_production)
var fake_production: int = 0:
	set(value):
		fake_production = maxi(0, lost_production)

var theft_protection_level: int = 0

var total_production: int:
	get():
		var total: int = actual_production + stolen_production + fake_production
		return total

enum ActionSelection {
	PRODUCE, ## Produce more real materials
	FORGE, ## Produce more fake materials
	SECURITY, ## Counter Stealing
	SABATOGE, ## Uncounterable, just destroys materials
	STEAL ## give yourself materials by screwing another guy
	}

var current_action: ActionSelection

func select_action(action: ActionSelection) -> void:
	match action:
		ActionSelection.PRODUCE:
			current_action = ActionSelection.PRODUCE
			open_approval("Increase Production")
		ActionSelection.FORGE:
			current_action = ActionSelection.FORGE
			open_approval("Forge Documents")
		ActionSelection.SECURITY:
			current_action = ActionSelection.SECURITY
			open_approval("Raise Security")
		ActionSelection.SABATOGE:
			current_action = ActionSelection.SABATOGE
			open_target_selection("Sabatoge")
		ActionSelection.STEAL:
			current_action = ActionSelection.STEAL
			open_target_selection("Steal")
		_:
			pass


func calculate_loss() -> void:
	lost_production = theft_manager.get_amount_lost()


func die() -> void:
	theft_manager.return_stolen()
	# Then visual stuff


func open_approval(title: String) -> void:
	approve_info.show()
	approve_info.title_label.text = title


func open_target_selection(title: String) -> void:
	target_select_info.show()
	target_select_info.title_lable.text = title


func _on_approve_info_no_button_pressed() -> void:
	approve_info.hide()


func _on_approve_info_yes_button_pressed() -> void:
	match current_action:
		ActionSelection.PRODUCE:
			real_production += production_increase_amount
		ActionSelection.FORGE:
			fake_production += forging_increase_amount
		ActionSelection.SECURITY:
			theft_protection_level += 1
		_:
			pass
	approve_info.hide()

func _on_target_select_info_player_selected(id: int) -> void:
	match current_action:
		ActionSelection.SABATOGE:
			# We get the player from Get_Player, then we remove sabatoge_amount
			pass
		ActionSelection.STEAL:
			theft_manager.steal(0)
			stolen_production = theft_manager.get_amount_stolen()


func _on_theft_manager_on_loss() -> void:
	calculate_loss()


func _on_production_button_pressed() -> void:
	select_action(ActionSelection.PRODUCE)


func _on_forge_button_pressed() -> void:
	select_action(ActionSelection.FORGE)


func _on_security_button_pressed() -> void:
	select_action(ActionSelection.SECURITY)


func _on_sabatoge_button_pressed() -> void:
	select_action(ActionSelection.SABATOGE)


func _on_steal_button_pressed() -> void:
	select_action(ActionSelection.STEAL)
