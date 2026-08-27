extends Node

const PORT: int = 8080

var is_ongoing_game: bool = false

func create_server() -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, 13)
	get_tree().get_multiplayer().multiplayer_peer = peer

func join_server(ip: String) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	get_tree().get_multiplayer().multiplayer_peer = peer
