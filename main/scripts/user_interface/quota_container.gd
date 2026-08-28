extends HBoxContainer
class_name QuotaContainer

@onready var report_label: Label = $ReportLabel
@onready var quota_amount_label: Label = $QuotaBar/QuotaAmountLabel
@onready var quota_bar: QuotaBar = $QuotaBar/QuotaBar

signal stat_data_added(stat_data: ProductionData)
var stat_datas: Dictionary[Stat, ProductionData]

func setup(report_number: int, quota: int) -> void:
	report_label.text = str(report_number)
	quota_amount_label.text = str(quota)

func add_stat_data(stat_data: ProductionData) -> void:
	if stat_datas.has(stat_data.stat):
		stat_datas[stat_data.stat].value = stat_data.value # This was +=, but we're using signals
	elif stat_data.value > 0.0:
		stat_data.min_value = 0.0
		stat_datas[stat_data.stat] = stat_data
		stat_data_added.emit(stat_data)

func _real_changed(amount: int) -> void:
	pass

func _fake_changed(amount: int) -> void:
	pass

func _stolen_changed(amount: int) -> void:
	pass
