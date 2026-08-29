extends Node2D
class_name MainGame

@onready var player_group: Node = $PlayerGroup
@onready var lobby: Node2D = %Lobby
@onready var stalin_view: StalinView = %StalinView
@onready var factory_view: FactoryView = %FactoryView
@onready var spectator_view: SpectatorView = %SpectatorView
@onready var lobby_camera: Camera2D = $Lobby/LobbyCamera

@onready var report_timer: Timer = $ReportTimer
@onready var player_list_container: GridContainer = $Lobby/ScrollContainer/PlayerListContainer
@onready var start_button: Button = $Lobby/StartButton
# Stalin Panel
# Factory Panel

const PLAYER_PANEL = preload("uid://b646t56seuksv")
const PLAYER = preload("uid://mhtuvanjpkj2")

## How much time it takes for stalin to get new report
@export var report_time: int = 120
## How many reports until the game ends
@export var total_reports: int = 10
@export var initial_total_quota = 100

var current_report_time: int = -1
var current_report: int = 0
@export var current_total_quota: int = 100

var factory_group: Array[int] = []
var stalin_player_id: int = -1

enum CameraViews {LOBBY, STALIN, FACTORY, SPECTATOR}
var current_camera: CameraViews = CameraViews.LOBBY

signal stalin_chosen()
signal update_report_time(time: int)
signal request_new_report()

func _ready() -> void:
	if !multiplayer.has_multiplayer_peer(): 
		Global.go_to_game()
	
	start_button.disabled = true
	
	if NetworkManager.is_host: # is_server() is not an alternative to host, just need to assign a host
		print("Joined as server")
		_add_player(1)
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player) # There will be an error, but no way to fix it.
	else:
		print("Joined as client")
		multiplayer.connected_to_server.connect(_server_connected)
		multiplayer.server_disconnected.connect(_server_disconnected)
		multiplayer.connection_failed.connect(_connection_failed)
	
	update_report_time.connect(stalin_view.bottom_ui_panel._update_report_time)
	update_report_time.connect(factory_view.bottom_ui_panel._update_report_time)

func get_players_as_int() -> Array[int]:
	var players: Array[int]
	var players_object: Array[Node] = player_group.get_children()
	for player: Player in players_object:
		players.push_back(int(player.name))
	print("Check list: %s" % [players])
	return players

func get_players_as_player() -> Array[Node]:
	var players: Array[Node]
	players = player_group.get_children()
	return players

func get_player_as_player(id: int) -> Player:
	for player: Player in get_players_as_player():
		if player.name == str(id):
			return player
	return null


@rpc("any_peer", "call_local", "reliable")
func give_name() -> String:
	return Global.player_name


func server_choose_stalin() -> void:
	if !NetworkManager.is_host: return
	var peers: Array[int] = get_players_as_int()
	var peer: int = peers[randi_range(0, peers.size() - 1)]
	sync_choose_stalin.rpc(peer)

@rpc("any_peer", "call_local", "reliable")
func sync_choose_stalin(peer_id: int) -> void: # Also includes host as they are also a player
	get_player_as_player(peer_id).is_stalin = true
	stalin_player_id = peer_id
	stalin_chosen.emit()

@rpc("any_peer", "call_local", "reliable")
func start_game() -> void:
	print("started game")
	multiplayer.multiplayer_peer.refuse_new_connections = true
	if NetworkManager.is_host:
		current_report = 0
		server_choose_stalin()
	
	# Then change the view depending if they are stalin.
	# Maybe use for to put them in respective


@rpc("any_peer", "call_local", "reliable")
func end_game() -> void:
	multiplayer.multiplayer_peer.refuse_new_connections = false
	if NetworkManager.is_host:
		start_button.disabled = false
		for player: Player in get_players_as_player():
			player.pay_timer.stop()
			player.set_active.rpc(false)
	
	put_into_lobby_view()
	report_timer.stop()


func put_into_lobby_view() -> void:
	lobby_camera.make_current()

func put_into_stalin_view() -> void:
	stalin_view.stalin_camera.make_current()


func put_into_factory_view() -> void:
	factory_view.factory_camera.make_current()


func put_into_spectator_view() -> void:
	spectator_view.spectator_camera.make_current()



@rpc("any_peer", "call_local", "reliable")
func request_report() -> void:
	print("%s: emit requesting report" % [multiplayer.multiplayer_peer]) 
	request_new_report.emit()

@rpc("any_peer", "call_local", "reliable")
func get_next_total_quota() -> void:
	current_total_quota *= 2


## This should only be an rpc_id
@rpc("any_peer", "call_local", "reliable")
func set_camera_view(view: CameraViews) -> void:
	current_camera = view
	match view: # We have camera's linked
		CameraViews.LOBBY:
			put_into_lobby_view()
		CameraViews.STALIN:
			put_into_stalin_view()
		CameraViews.FACTORY:
			put_into_factory_view()
		CameraViews.SPECTATOR:
			put_into_spectator_view()
		_:
			pass


@rpc("any_peer", "call_local", "reliable")
func refresh_player_panels() -> void:
	await get_tree().create_timer(0.5).timeout
	for child: PlayerPanel in player_list_container.get_children():
		child.queue_free()
	
	for player: Player in get_players_as_player():
		var player_panel: PlayerPanel = PLAYER_PANEL.instantiate()
		
		player_list_container.add_child(player_panel)
		player_panel.name_label.text = player.real_name
		player_panel.owner_id = int(player.name)
		player_panel.show_hide_kick()
	
	if NetworkManager.is_host:
		if get_players_as_player().size() >= 2:
			start_button.disabled = false
		else:
			start_button.disabled = true

func _add_player(id: int) -> void:
	if !multiplayer.is_server(): return
	var player: Player = PLAYER.instantiate()
	
	player.name = str(id)
	
	player_group.add_child(player)
	
	player.player_ready.connect(_player_is_ready)
	request_new_report.connect(player._deal_new_report)
	print("%s is connected: %s" % [player, request_new_report.is_connected(player._deal_new_report)])
	
	player.assign_identity.rpc(id)

func _remove_player(id: int) -> void:
	print("leave server")
	for player: Player in get_players_as_player():
		if player.get_multiplayer_authority() == id:
			player.queue_free()
			
			factory_group.erase(id)
			if factory_group.is_empty():
				end_game.rpc()
			
			if stalin_player_id == id:
				stalin_player_id = -1
				end_game.rpc()
			
			refresh_player_panels.rpc()

func _player_is_ready() -> void:
	refresh_player_panels.rpc()

func _server_connected() -> void:
	pass

func _server_disconnected() -> void:
	NetworkManager.leave_server()
	Global.go_to_main_menu()
	queue_free()

func _connection_failed() -> void:
	pass


func _on_exit_button_pressed() -> void:
	NetworkManager.leave_server() # Should trigger [method MainGame._remove_player]
	Global.go_to_main_menu()
	queue_free()


func _on_start_button_pressed() -> void:
	start_button.disabled = true
	start_game()


func _on_stalin_chosen() -> void:
	print("found stalin")
	
	if NetworkManager.is_host:
		report_timer.start()
		report()
		factory_group.clear()
		
		for id: int in get_players_as_int():
			if id != stalin_player_id:
				set_camera_view.rpc_id(id, CameraViews.FACTORY)
				factory_group.append(id)
			else:
				set_camera_view.rpc_id(id, CameraViews.STALIN)
				
				
			
			var player: Player = get_player_as_player(id)
			player.ready_player.rpc_id(id)
		
		for player: Player in get_players_as_player():
			player.pay_timer.start()
			player.set_active.rpc(true)
			
			if player.is_stalin:
				player.stalin_manager.add_factories.rpc_id(int(player.name))


func _on_report_timer_timeout() -> void:
	if NetworkManager.is_host:
		current_report_time -= 1
		
		update_report_time.emit(current_report_time)
		
		if current_report_time <= 0:
			print("Time below 0")
			report()


func report() -> void:
	if !NetworkManager.is_host: return
	print("reporting")
	current_report_time = report_time
	current_report += 1
	get_next_total_quota.rpc()
	request_report.rpc() # For some reason it is stopping here
	
	if current_report >= total_reports:
		end_game.rpc()
