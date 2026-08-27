extends Node
class_name Player

var real_name: String = "Player"
var is_stalin: bool = false

@onready var stalin_manager: StalinManager = $StalinManager
@onready var factory_manager: FactoryManager = $FactoryManager

signal player_ready()

func _ready() -> void:
	_change_name.rpc()

@rpc("any_peer","call_local", "reliable")
func _change_name() -> void:
	real_name = Global.player_name
