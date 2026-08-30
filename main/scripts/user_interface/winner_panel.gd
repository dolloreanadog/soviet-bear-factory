extends Panel
class_name WinnerPanel

@onready var stalin_label: Label = $StalinLabel
@onready var winner_list: RichTextLabel = $VBoxContainer/WinnerList

@rpc("any_peer", "call_local",  "reliable")
func setup() -> void:
	var main_game: MainGame = get_tree().get_first_node_in_group("MainGame")
	if main_game.stalin_player_id == -1: return
	show()
	
	print("Win Condition: %s/%s" % [main_game.get_player_as_player(main_game.stalin_player_id).stalin_manager.get_total_real_production(), main_game.previous_total_quota])
	if main_game.get_player_as_player(main_game.stalin_player_id).stalin_manager.get_total_real_production() >= main_game.previous_total_quota:
		stalin_label.text = "Stalin Wins"
	else:
		stalin_label.text = "Stalin Loses"
	
	for player: Player in main_game.get_players_as_player():
		if player.is_stalin: continue
		if player.is_active:
			winner_list.text += "%s\n" % [player.real_name]

@rpc("any_peer", "call_local", "reliable")
func _sync(stalin_text: String, winner_text: String) -> void:
	stalin_label.text = stalin_text
	winner_list.text = winner_text

func _on_back_button_pressed() -> void:
	var main_game: MainGame = get_tree().get_first_node_in_group("MainGame")
	main_game._on_exit_button_pressed()
