extends ColorRect
class_name TargetSelectInfo

const TARGET_CONTAINER = preload("uid://e78yueve5sgu")

@onready var grid_container: GridContainer = $GridContainer
@onready var title_lable: Label = $TitleLable

# TODO: You would want

func create_debug_target() -> void:
	var target: TargetContainer = TARGET_CONTAINER.instantiate()
	grid_container.add_child(target)
	target.pressed.connect(_on_target_container_pressed)
	target.check_for_quota()
	# Change name, icon, & check quota


func _on_target_container_pressed(id: int) -> void:
	hide()
