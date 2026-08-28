extends Node
class_name FactoryManager

const QUOTA_CONTAINER = preload("uid://deo83hywn4hhu")

@onready var player: Player = get_parent()
@onready var theft_manager: TheftManager = $TheftManager

@export_group("Initial")
@export var initial_production: int = 200
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

var current_quota_container: QuotaContainer

signal real_production_changed(amount: int)
signal fake_production_changed(amount: int)
signal stolen_production_changed(amount: int)

func _ready() -> void:
	pass

func get_current_quota() -> int:
	@warning_ignore("integer_division")
	var quota: int = player.main_game.current_total_quota / player.main_game.get_players_as_int().size()
	return quota

func create_quota_bar() -> void:
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
	real_production_changed.emit(real_production)
	fake_production_changed.emit(fake_production)
	stolen_production_changed.emit(stolen_production)
