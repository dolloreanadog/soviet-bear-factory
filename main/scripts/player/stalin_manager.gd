extends Node
class_name StalinManager

@onready var player_owner: Player = get_parent()

const QUOTA_CONTAINER = preload("uid://deo83hywn4hhu")

const REAL_STAT = preload("uid://doylyrxfo8wqf")

# These two for investigation
const FAKE_STAT = preload("uid://bsb6rd3kpn2pe")
const STOLEN_STAT = preload("uid://cfovuok7at7d8")

func get_total_production() -> int:
	var total_production: int = 0
	for player: Player in owner.main_game.get_players_as_player():
		total_production += player.factory_manager.total_production
	
	return total_production

func get_total_real_production() -> int:
	var total_production: int = 0
	for player: Player in owner.main_game.get_players_as_player():
		print("%s has %s" % [player.name, str(player.factory_manager.real_production)])
		total_production += player.factory_manager.real_production
	
	return total_production

func new_report() -> void:
	create_quota_bar()
	_update_factories()

func create_quota_bar() -> void:
	if !is_multiplayer_authority(): return
	if !player_owner.is_stalin: return
	
	var quota_container: QuotaContainer = QUOTA_CONTAINER.instantiate()
	
	player_owner.stalin_view.bottom_ui_panel.report_container.add_child(quota_container)
	player_owner.stalin_view.bottom_ui_panel.report_container.move_child(quota_container, 0)
	quota_container.setup(player_owner.main_game.current_report - 1, player_owner.main_game.previous_total_quota)
	
	print("Real Changed")
	var production_data: ProductionData = ProductionData.new()
	production_data.stat = REAL_STAT
	production_data.value = player_owner.main_game.get_total_production()
	quota_container.add_stat_data(production_data)

func create_investigate_bar(id: int) -> void:
	if !is_multiplayer_authority(): return
	if !player_owner.is_stalin: return
	
	var quota_container: QuotaContainer = QUOTA_CONTAINER.instantiate()
	
	var target_player: Player = player_owner.main_game.get_player_as_player(id)
	
	player_owner.stalin_view.investigation_document.name_label.text = target_player.main_game.get_player_as_player(id).real_name
	player_owner.stalin_view.investigation_document.show()
	if player_owner.stalin_view.investigation_document.report_container.get_child_count() > 0:
		player_owner.stalin_view.investigation_document.report_container.get_child(0).queue_free()
	player_owner.stalin_view.investigation_document.report_container.add_child(quota_container)
	quota_container.setup(player_owner.main_game.current_report, player_owner.main_game.current_total_quota)
	
	print("Investigation found: %s/%s/%s from %s" % [target_player.factory_manager.real_production, target_player.factory_manager.fake_production, target_player.factory_manager.stolen_production, id])
	var production_data: ProductionData = ProductionData.new()
	production_data.stat = REAL_STAT
	production_data.value = target_player.factory_manager.real_production
	quota_container.add_stat_data(production_data)
	
	production_data = ProductionData.new()
	production_data.stat = FAKE_STAT
	production_data.value = target_player.factory_manager.fake_production
	quota_container.add_stat_data(production_data)
	
	production_data = ProductionData.new()
	production_data.stat = FAKE_STAT
	production_data.value = target_player.factory_manager.stolen_production
	quota_container.add_stat_data(production_data)
	
	await get_tree().create_timer(5).timeout
	player_owner.stalin_view.investigation_document.hide()

func _update_factories() -> void:
	if !is_multiplayer_authority(): return
	if !player_owner.is_stalin: return
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
	player_owner.decrease_ruble(500)
	create_investigate_bar(id)

func _execute(id: int) -> void:
	if !is_multiplayer_authority(): return
	player_owner.main_game.get_player_as_player(id).close_factory.rpc()
