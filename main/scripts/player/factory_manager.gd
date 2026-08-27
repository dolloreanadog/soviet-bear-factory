extends Node
class_name FactoryManager

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


func _ready() -> void:
	pass

func create_quota_bar() -> void:
	pass
