extends Node2D
class_name StalinView

var main_game: MainGame

@onready var stalin_camera: Camera2D = $StalinCamera
@onready var bottom_ui_panel: BottomUIPanel = $StalinCamera/BottomUIPanel
@onready var factory_grid: GridContainer = $ScrollContainer/FactoryGrid

const FACTORY_PANEL = preload("uid://cuqbtrlqdc5ve")

func _ready() -> void:
	main_game = get_tree().get_first_node_in_group("MainGame")

func add_factories() -> Array[FactoryPanel]:
	var array: Array[FactoryPanel]
	
	for player: Player in main_game.get_players_as_player():
		if player.is_stalin: continue
		var factory: FactoryPanel = FACTORY_PANEL.instantiate()
		factory.factory_id = int(player.name)
		factory_grid.add_child(factory)
		
		factory.name_label.text = player.real_name
		#player.factory_closed.connect(factory.close)
		
		array.append(factory)
	
	return array

func clear_factories() -> void:
	for factory: FactoryPanel in factory_grid.get_children():
		factory.queue_free()

func update_factories() -> void:
	for factory: FactoryPanel in factory_grid.get_children():
		if factory.current_status == FactoryPanel.FactoryStatus.DEAD: continue
		var player: Player = main_game.get_player_as_player(factory.factory_id)
		
		if player.factory_manager.is_meeting_quota():
			factory.choose_status(FactoryPanel.FactoryStatus.GOOD)
		else:
			factory.choose_status(FactoryPanel.FactoryStatus.BAD)
		#factory.choose_status()
