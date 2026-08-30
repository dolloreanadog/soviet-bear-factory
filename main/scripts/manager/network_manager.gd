extends Node

const PORT: int = 8080
const MAX_PLAYERS: int = 13

var is_ongoing_game: bool = false
var is_host: bool = false

func create_server() -> void:
	is_host = true
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	push_warning("we're also doing this as %s" % [multiplayer.get_unique_id()])

func join_server(ip: String) -> void:
	is_host = false
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(ip, PORT)
	push_error(error)
	multiplayer.multiplayer_peer = peer
	push_warning("Joining server as %s" % [multiplayer.get_unique_id()])

func leave_server() -> void:
	is_host = false
	multiplayer.multiplayer_peer.close()
