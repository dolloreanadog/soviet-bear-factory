class_name ProductionData
extends Resource


signal value_changed
@export var stat: Stat
@export var value: float:
	set = set_value
@export var min_value: float = -INF
@export var max_value: float = INF


func set_value(_value: float) -> void:
	_value = clampf(_value, min_value, max_value)
	value = _value
	value_changed.emit()
