extends Node2D
class_name StalinView



@onready var real_info: InvestigationReport = %RealInfo
@onready var factory_grid_container: GridContainer = %FactoryGridContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player_selected: int = -1

signal ability_pressed()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for factory: FactoryOwnerPanel in factory_grid_container.get_children():
		factory.info_pressed.connect(_info_pressed)
		factory.investigate_pressed.connect(_investigate_ability_pressed)
		factory.boost_pressed.connect(_execute_ability_pressed)
		factory.execute_pressed.connect(_execute_ability_pressed)
		ability_pressed.connect(factory.buttons_cooldown)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func change_view(is_main: bool) -> void:
	if is_main:
		animation_player.play("main")
	else:
		animation_player.play("in_depth")


func create_factory(id: int) -> void:
	# adds a player factory
	# also link the button signals
	pass

## This will print an in depth look onto the player that stalin ordered investigated
func print_investigation_report(id: int) -> void:
	real_info.animation_player.play(&"drop")
	real_info.animation_player.queue(&"idle")


func _info_pressed(id: int) -> void:
	change_view(false)


func _execute_ability_pressed(id: int) -> void:
	ability_pressed.emit()


func _boost_ability_pressed(id: int) -> void:
	ability_pressed.emit()


func _investigate_ability_pressed(id: int) -> void:
	print_investigation_report(id)
	ability_pressed.emit()



func _on_back_button_pressed() -> void:
	change_view(true)
