extends TextureRect
class_name TargetSelectionDoc

const TARGET_PANEL = preload("uid://dk4lm2sl7jxn2")

@onready var title_label: Label = $TitleLabel
@onready var grid_container: GridContainer = $ScrollContainer/GridContainer

signal target_selected(id: int)

func add_targets() -> void:
	# TODO : I have a feeling this needs to be done in factory manager where the player actually has authropity
	print("Doing Targets")
	var main_game: MainGame = get_tree().get_first_node_in_group("MainGame")
	
	for player: Player in main_game.get_players_as_player():
		add_target(player)

func add_target(player: Player) -> void:
	if player.is_stalin or !player.is_active or get_multiplayer_authority() == int(player.name): return
	
	var target_panel: TargetPanel = TARGET_PANEL.instantiate()
	
	grid_container.add_child(target_panel)
	target_panel.check_quota_status()
	target_panel.target_id = int(player.name)
	target_panel.name_label.text = player.real_name
	target_panel.target_selected.connect(target_was_selected)

func target_was_selected(id: int) -> void:
	target_selected.emit(id)
	hide()
