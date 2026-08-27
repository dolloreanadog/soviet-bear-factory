extends Node
class_name Player

var real_name: String = "Player"
var is_stalin: bool = false

@onready var stalin_manager: StalinManager = $StalinManager
@onready var factory_manager: FactoryManager = $FactoryManager

signal player_ready()

func _ready() -> void:
	pass
	#if is_multiplayer_authority():
		#_change_name.rpc(Global.player_name)

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
