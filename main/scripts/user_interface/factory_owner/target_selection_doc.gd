extends TextureRect
class_name TargetSelectionDoc

const TARGET_PANEL = preload("uid://dk4lm2sl7jxn2")

@onready var title_label: Label = $TitleLabel
@onready var grid_container: GridContainer = $ScrollContainer/GridContainer

signal target_selected(id: int)

func add_targets() -> void:
	print("Doing Targets") # This is fine
	var main_game: MainGame = get_tree().get_first_node_in_group("MainGame")
	
	for player: Player in main_game.get_players_as_player():
		add_target(player)

func add_target(player: Player) -> void:
	# TODO: Split up if statement and add individual print to figure it out
	# TODO: What is happening here is to figure at what point client can no longer see
	print("Seems alright 1")
	#if player.is_stalin or !player.is_active or multiplayer.get_unique_id() == int(player.name): return
	if player.is_stalin: return
	print("Seems alright 2")
	if !player.is_active: return
	print("Seems alright 3") # We can't see this
	if multiplayer.get_unique_id() == int(player.name): return
	print("Seems alright 4") # We can't see this
	if player.factory_manager.real_production <= player.factory_manager.steal_increase_amount: return
	
	var target_panel: TargetPanel = TARGET_PANEL.instantiate()
	
	grid_container.add_child(target_panel)
	target_panel.target_id = int(player.name)
	target_panel.name_label.text = player.real_name
	target_panel.target_selected.connect(target_was_selected)
	target_panel.check_quota_status()

func target_was_selected(id: int) -> void:
	target_selected.emit(id)
	hide()


func _on_exit_button_pressed() -> void:
	hide()
