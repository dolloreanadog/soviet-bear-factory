extends Node
class_name FactoryManager

const QUOTA_CONTAINER = preload("uid://deo83hywn4hhu")

@onready var player: Player = get_parent()
@onready var theft_manager: TheftManager = $TheftManager

@export_group("Initial")
@export var initial_production: int = 0
@export_group("Costs")
@export var production_cost: int = 200
@export var forge_cost: int = 100
@export var security_cost: int = 200
@export var sabatoge_cost: int = 100
@export var steal_cost: int = 300
@export_group("Upgrades")
@export var production_increase_amount: int = 5
@export var forging_increase_amount: int = 10
@export var sabatoge_amount = 5
@export var steal_increase_amount: int = 10
@export_group("Production")
## The actual amount of production unaffected by stealing
@export var real_production: int = 0: # TODO: Probably have this emit a signal if we edit it
	set(value):
		real_production = value
		#real_production_changed.emit(actual_production)
		update_current_info()
## How much they're actually producing real production - stolen
var actual_production: int:
	get():
		return real_production - lost_production
## How much is being currently stolen for our own production
@export var lost_production: int = 0:
	set(value):
		lost_production = maxi(0, value)
## How much of it is stolen from others
@export var stolen_production: int = 0:
	set(value):
		stolen_production = maxi(0, value)
		#stolen_production_changed.emit(stolen_production)
		update_current_info()
@export var fake_production: int = 0:
	set(value):
		fake_production = maxi(0, value)
		#fake_production_changed.emit(fake_production)
		update_current_info()
var total_production: int:
	get():
		var total: int = real_production + stolen_production + fake_production
		return total

enum ActionSelection {
	PRODUCE, ## Produce more real materials
	FORGE, ## Produce more fake materials
	SECURITY, ## Counter Stealing
	SABATOGE, ## Uncounterable, just destroys materials
	STEAL ## give yourself materials by screwing another guy
	}
var current_action: ActionSelection

var current_quota_container: QuotaContainer

signal real_production_changed(amount: int)
signal fake_production_changed(amount: int)
signal stolen_production_changed(amount: int)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	check_buttons_available()

func get_current_quota() -> int:
	@warning_ignore("integer_division")
	print("Player size: %s" % [player.main_game.current_total_quota])
	print("Player size: %s" % [player.main_game.get_players_as_player().size()])
	var quota: int = player.main_game.current_total_quota / (player.main_game.get_players_as_player().size() - 1)
	return quota

func get_past_quota() -> int:
	@warning_ignore("integer_division")
	print("Player size: %s" % [player.main_game.current_total_quota])
	print("Player size: %s" % [player.main_game.get_players_as_player().size()])
	var quota: int = player.main_game.previous_total_quota / (player.main_game.get_players_as_player().size() - 1)
	return quota

func create_quota_bar() -> void: # TODO: Add something similar to Stalin
	if !is_multiplayer_authority(): return
	if player.is_stalin: return
	print("Create Factory Quota Bar")
	if is_instance_valid(current_quota_container):
		real_production_changed.disconnect(current_quota_container._real_changed)
		fake_production_changed.disconnect(current_quota_container._fake_changed)
		stolen_production_changed.disconnect(current_quota_container._stolen_changed)
	
	var quota_container: QuotaContainer = QUOTA_CONTAINER.instantiate()
	current_quota_container = quota_container
	
	player.main_game.factory_view.bottom_ui_panel.report_container.add_child(quota_container)
	player.main_game.factory_view.bottom_ui_panel.report_container.move_child(quota_container, 0)
	quota_container.setup(player.main_game.current_report, player.factory_manager.get_current_quota())
	
	
	real_production_changed.connect(quota_container._real_changed)
	fake_production_changed.connect(quota_container._fake_changed)
	stolen_production_changed.connect(quota_container._stolen_changed)
	
	update_current_info()

func update_current_info() -> void:
	real_production_changed.emit(actual_production)
	fake_production_changed.emit(fake_production)
	stolen_production_changed.emit(stolen_production)

func select_action(action: ActionSelection) -> void:
	if !is_multiplayer_authority(): return
	match action:
		ActionSelection.PRODUCE:
			current_action = ActionSelection.PRODUCE
			player.factory_view.open_approval("Increase Production")
			#player.decrease_ruble(production_cost) # TODO: Remove this, approve this in approval
			#open_approval("Increase Production")
		ActionSelection.FORGE:
			current_action = ActionSelection.FORGE
			player.factory_view.open_approval("Forge Documents")
			#player.decrease_ruble(forge_cost)
			#open_approval("Forge Documents")
		ActionSelection.SECURITY:
			current_action = ActionSelection.SECURITY
			player.factory_view.open_approval("Raise Security")
			#player.decrease_ruble(security_cost)
			#open_approval("Raise Security")
		ActionSelection.SABATOGE:
			current_action = ActionSelection.SABATOGE
			player.factory_view.open_target_selection("Sabatoge Another")
			for target: TargetPanel in player.factory_view.target_selection_doc.grid_container.get_children():
				target.queue_free()
			player.factory_view.target_selection_doc.add_targets()
			#player.decrease_ruble(sabatoge_cost)
			#open_target_selection("Sabatoge")
		ActionSelection.STEAL:
			current_action = ActionSelection.STEAL
			player.factory_view.open_target_selection("Steal Production")
			for target: TargetPanel in player.factory_view.target_selection_doc.grid_container.get_children():
				target.queue_free()
			player.factory_view.target_selection_doc.add_targets()
			#player.decrease_ruble(steal_cost)
			#open_target_selection("Steal")
		_:
			pass
	
	#do_nontarget_action() # TODO: Temporary, until approval page is done

func do_nontarget_action() -> void:
	match current_action:
		ActionSelection.PRODUCE:
			real_production += production_increase_amount
			player.decrease_ruble(production_cost)
		ActionSelection.FORGE:
			fake_production += forging_increase_amount
			player.decrease_ruble(forge_cost)
		ActionSelection.SECURITY:
			theft_manager.theft_protection_level += 1
			player.decrease_ruble(security_cost)
		_:
			pass

func do_targeted_action(id: int) -> void:
	if !is_multiplayer_authority(): return
	print("%s: Removing from %s" % [multiplayer.get_unique_id(), id])
	var selected: Player = player.main_game.get_player_as_player(id)
	
	match current_action:
		ActionSelection.SABATOGE:
			# We get the player from Get_Player, then we remove sabatoge_amount
			selected.factory_manager.remove_production.rpc_id(id, sabatoge_amount)
			player.decrease_ruble(sabatoge_cost)
		ActionSelection.STEAL:
			stolen_production += steal_increase_amount
			selected.factory_manager.remove_production.rpc_id(id, steal_increase_amount)
			player.decrease_ruble(steal_cost)
			#theft_manager.steal(0)
			#stolen_production = theft_manager.get_amount_stolen()

@rpc("any_peer", "call_local", "reliable")
func remove_production(amount: int) -> void:
	print("Remove production")
	real_production -= amount
	print("%s: Remove production: %s" % [multiplayer.get_unique_id() , real_production])
	update_current_info()

@rpc("any_peer", "call_local", "reliable")
func sync_production(amount: int) -> void:
	real_production = amount

func calculate_loss() -> void:
	pass
	#lost_production = theft_manager.get_amount_lost()

func is_meeting_quota() -> bool:
	print("Current Quota: %s/%s" % [total_production, get_current_quota()])
	if total_production >= get_current_quota():
		return true
	else:
		return false

func has_met_quota() -> bool:
	print("Current Quota: %s/%s" % [total_production, get_past_quota()])
	if total_production >= get_past_quota():
		return true
	else:
		return false

func check_buttons_available() -> void:
	if !is_multiplayer_authority(): return
	if player.ruble >= production_cost and player.is_active:
		player.factory_view.production_button.disabled = false
	else:
		player.factory_view.production_button.disabled = true
	
	if player.ruble >= forge_cost and player.is_active:
		player.factory_view.forge_button.disabled = false
	else:
		player.factory_view.forge_button.disabled = true
	
	if player.ruble >= security_cost and player.is_active:
		player.factory_view.security_button.disabled = false
	else:
		player.factory_view.security_button.disabled = true
	
	if player.ruble >= sabatoge_cost and player.is_active:
		player.factory_view.sabatoge_button.disabled = false
	else:
		player.factory_view.sabatoge_button.disabled = true
	
	if player.ruble >= steal_cost and player.is_active:
		player.factory_view.steal_button.disabled = false
	else:
		player.factory_view.steal_button.disabled = true

func _action_selected() -> void:
	do_nontarget_action()

func _target_selected(id: int) -> void:
	do_targeted_action(id)
