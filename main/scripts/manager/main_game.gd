extends Node2D
class_name MainGame

@onready var player_group: MultiplayerSpawner = $PlayerGroup
@onready var lobby: Node2D = $Lobby
@onready var stalin_view: StalinView = $StalinView
@onready var factory_view: FactoryView = $FactoryView
@onready var spectator_view: SpectatorView = $SpectatorView
@onready var player_list_container: GridContainer = $Lobby/ScrollContainer/PlayerListContainer
# Stalin Panel
# Factory Panel

const PLAYER_PANEL = preload("uid://b646t56seuksv")
const PLAYER = preload("uid://mhtuvanjpkj2")

var factory_group: Array[int]
var stalin_player_id: int

func _ready() -> void:
	if !multiplayer.has_multiplayer_peer(): 
		Global.go_to_game()
	
	if multiplayer.is_server():
		push_warning("Joined as server")
		_add_player(1)
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.disconnect(_remove_player) # There will be an error, but no way to fix it.
	else:
		push_warning("Joined as client")
		multiplayer.connected_to_server.connect(_server_connected)
		multiplayer.server_disconnected.connect(_server_disconnected)
		multiplayer.connection_failed.connect(_connection_failed)
		
	print("Check list: %s" % [multiplayer.get_unique_id()])
	print("Check list: %s" % [multiplayer.get_peers()])

func get_players_as_int() -> Array[int]:
	var players: Array[int]
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


#region Getting Player Name

#func give_names_to_server() -> void:
	#pass
#
@rpc("any_peer", "call_local", "reliable")
func give_name() -> String:
	return Global.player_name
#endregion


func server_choose_stalin() -> void:
	if !multiplayer.is_server(): return
	var peers: PackedInt32Array = multiplayer.get_peers()
	var peer: int = peers[randi_range(0, peers.size() - 1)]
	sync_choose_stalin.rpc(peer)
	

@rpc("any_peer", "call_local", "reliable")
func sync_choose_stalin(peer_id: int) -> void: # Also includes host as they are also a player
	get_player_as_player(peer_id).is_stalin = true

func start_game() -> void:
	server_choose_stalin()
	# Then change the view depending if they are stalin.
	# Maybe use for to put them in respective


## Put the player as stalin
@rpc("any_peer", "call_local", "reliable")
func put_into_stalin_view(id: int) -> void:
	set_stalin_view.rpc_id(id)

func set_stalin_view() -> void:
	pass

@rpc("any_peer", "call_local", "reliable")
func put_into_factory_view(id: int) -> void:
	set_factory_view.rpc_id(id)

func set_factory_view() -> void:
	pass

@rpc("any_peer", "call_local", "reliable")
func put_into_spectator_view(id: int) -> void:
	set_spectator_view.rpc_id(id)

func set_spectator_view() -> void:
	pass

func end_game() -> void:
	pass


@rpc("any_peer", "call_local", "reliable")
func _refresh_player_panels() -> void:
	print("hello")
	for child: PlayerPanel in player_list_container.get_children():
		child.queue_free()
	
	for player: Player in get_players_as_player():
		var player_panel: PlayerPanel = PLAYER_PANEL.instantiate()
		
		player_list_container.add_child(player_panel)
		player_panel.name_label.text = player.real_name

func _add_player(id: int) -> void:
	if !multiplayer.is_server(): return
	var player: Player = PLAYER.instantiate()
	player_group.add_child(player)
	
	player.name = str(id)
	
	player.player_ready.connect(_player_is_ready)
	_refresh_player_panels()

func _remove_player(id: int) -> void:
	pass

func _player_is_ready() -> void:
	_refresh_player_panels.rpc()

func _server_connected() -> void:
	pass

func _server_disconnected() -> void:
	pass

func _connection_failed() -> void:
	pass
