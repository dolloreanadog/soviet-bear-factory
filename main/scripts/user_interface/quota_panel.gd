extends Panel
class_name QuotaPanel

# TODO: We're going to need to create two types of quota containers

const STALIN_QUOTA_CONTAINER = preload("uid://c8dna0miy8nnd")
#
#const FACTORY_QUOTA_CONTAINER

@onready var quota_holder: VBoxContainer = $ScrollContainer/QuotaHBoxContainer
@onready var scroll_container: ScrollContainer = $ScrollContainer

## Eventually Stalin & Factory Owner will be merged and would be a child of the GameManagerNode
var current_report: int = 0

func _ready() -> void:
	debug_create_container()

func create_stalin_container(value: int, max_value: int) -> void:
	var quota: QuotaContainer = STALIN_QUOTA_CONTAINER.instantiate()
	quota_holder.add_child(quota)
	quota_holder.move_child(quota, 0)
	quota.set_amount(value, max_value)
	quota.report_number = current_report
	
	current_report += 1

func create_factory_container(real_value: int, stolen_value: int, fake_value: int, max_value: int) -> void:
	pass

func debug_create_container() -> void:
	create_stalin_container(0, 100)
