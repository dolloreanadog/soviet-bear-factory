extends Node
class_name StalinManager

@onready var player_owner: Player = get_parent()

func get_total_production() -> int:
	var total_production: int = 0
	for player: Player in owner.main_game.get_players_as_player():
		total_production = player.factory_manager.total_production
	
	return total_production

func new_report() -> void:
	create_quota_bar()
	_update_factories()

func create_quota_bar() -> void:
	pass

func create_investigate_bar(id: int) -> void:
	pass

func _update_factories() -> void:
	if !is_multiplayer_authority(): return
	player_owner.stalin_view.update_factories()

@rpc("any_peer", "call_local", "reliable")
func add_factories() -> void:
	if !is_multiplayer_authority(): return
	print("adding factories")
	var factories: Array[FactoryPanel] = player_owner.stalin_view.add_factories()
	
	for factory: FactoryPanel in factories:
		factory.boost_pressed.connect(_boost)
		factory.investigate_pressed.connect(_investigate)
		factory.execute_pressed.connect(_execute)
	
	_update_factories()

func _boost(id: int) -> void:
	if !is_multiplayer_authority(): return
	player_owner.decrease_ruble(100)
	player_owner.main_game.get_player_as_player(id).increase_ruble.rpc_id(id, 100)

func _investigate(id: int) -> void:
	if !is_multiplayer_authority(): return
	player_owner.decrease_ruble(300)
	create_investigate_bar(id)

func _execute(id: int) -> void:
	if !is_multiplayer_authority(): return
	player_owner.main_game.get_player_as_player(id).close_factory.rpc()
