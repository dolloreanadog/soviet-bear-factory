extends Node
class_name Player

var real_name: String = "Player"
var is_stalin: bool = false

var main_game: MainGame
var lobby: Node2D
var stalin_view: StalinView
var factory_view: FactoryView
var spectator_view: SpectatorView

@onready var pay_timer: Timer = $FactoryManager/PayTimer
@onready var stalin_manager: StalinManager = $StalinManager
@onready var factory_manager: FactoryManager = $FactoryManager

@export var _initial_factory_ruble: int = 100
@export var _initial_stalin_ruble: int = 500

@export var ruble: int = 0

#var current_quota_bar: 

signal player_ready()
signal ruble_changed(amount: int)

func _ready() -> void:
	main_game = get_tree().get_first_node_in_group("MainGame")
	stalin_view = main_game.stalin_view
	factory_view = main_game.factory_view
	spectator_view = main_game.spectator_view
	lobby = main_game.lobby
	
	ruble_changed.connect(factory_view.bottom_ui_panel._update_ruble)
	ruble_changed.connect(stalin_view.bottom_ui_panel._update_ruble)
	
	factory_view.action_selected.connect(factory_manager.select_action)
	factory_view.approval_doc.accept_button_pressed.connect(factory_manager._action_selected)

@rpc("any_peer","call_local", "reliable")
func _change_name(player_name: String) -> void:
	real_name = player_name
	player_ready.emit()

@rpc("any_peer","call_local", "reliable")
func assign_identity(id: int) -> void:
	set_multiplayer_authority(id)
	name = str(id)
	if is_multiplayer_authority():
		_change_name.rpc(Global.player_name)

@rpc("any_peer","call_local", "reliable")
func increase_ruble(amount: int) -> void:
	if is_multiplayer_authority():
		ruble += amount
		ruble_changed.emit(ruble)

@rpc("any_peer","call_local", "reliable")
func decrease_ruble(amount: int) -> void:
	if is_multiplayer_authority():
		if has_enough_ruble(amount):
			ruble -= amount
			ruble_changed.emit(ruble)
		else:
			print("Not enough ruble")

func has_enough_ruble(decrease_amount: int) -> bool:
	if ruble - decrease_amount < 0:
		return false
	return true

@rpc("any_peer", "call_local", "reliable")
func ready_player() -> void:
	if is_multiplayer_authority():
		factory_manager.real_production = factory_manager.initial_production
		
		if is_stalin:
			ruble = _initial_stalin_ruble
		else:
			ruble = _initial_factory_ruble
		
		ruble_changed.emit(ruble)

func _deal_new_report() -> void:
	_new_report.rpc()

@rpc("any_peer", "call_local", "reliable")
func _new_report() -> void:
	if !is_multiplayer_authority(): return
	if is_stalin:
		increase_ruble(500)
	else:
		factory_manager.create_quota_bar()

func _on_pay_timer_timeout() -> void:
	if NetworkManager.is_host:
		_give_factory_pay.rpc()

@rpc("any_peer", "call_local", "reliable")
func _give_factory_pay() -> void:
	if !is_multiplayer_authority(): return
	if is_stalin: return
	increase_ruble(100)
