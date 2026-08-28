extends PanelContainer
class_name QuotaBar

signal depleted
const PRODUCTION_CONTAINER = preload("uid://dbu3m7uc0572l")
@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var stamina: PanelContainer = $HBoxContainer/QuotaLeft


func _ready() -> void:
	for child: Node in h_box_container.get_children():
		if child is not ProductionContainer:
			continue
		var stat_container: ProductionContainer = child
		stat_container.value_changed.connect(_on_stat_container_value_changed)


func _on_stat_container_value_changed() -> void:
	if stamina.size.x == 0.0:
		depleted.emit()


func add_stat_data(stat_data: ProductionData) -> void:
	var stat_container: ProductionContainer
	for child: Node in h_box_container.get_children():
		if child is not ProductionContainer:
			continue
		stat_container = child
		if stat_container.stat_data.stat == stat_data.stat:
			return
	stat_container = PRODUCTION_CONTAINER.instantiate()
	h_box_container.add_child(stat_container)
	stat_container.stat_data = stat_data
	stat_container.value_changed.connect(_on_stat_container_value_changed)
