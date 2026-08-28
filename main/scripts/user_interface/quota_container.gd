extends HBoxContainer
class_name QuotaContainer

@onready var report_label: Label = $ReportLabel
@onready var quota_amount_label: Label = $QuotaBar/QuotaAmountLabel
@onready var quota_bar: QuotaBar = $QuotaBar/QuotaBar

const FAKE_STAT = preload("uid://bsb6rd3kpn2pe")
const REAL_STAT = preload("uid://doylyrxfo8wqf")
const STOLEN_STAT = preload("uid://cfovuok7at7d8")

signal stat_data_added(stat_data: ProductionData)
var stat_datas: Dictionary[Stat, ProductionData]

func setup(report_number: int, quota: int) -> void:
	report_label.text = str(report_number)
	quota_amount_label.text = str(quota)

func add_stat_data(stat_data: ProductionData) -> void: # TODO: We keep adding new stat_data
	print("%s: adding stat: %s" % [multiplayer.multiplayer_peer, stat_datas])
	print("%s: adding stat name: %s" % [multiplayer.multiplayer_peer, stat_data.stat.name])
	if stat_datas.has(stat_data.stat):
		print("adding to existing")
		stat_datas[stat_data.stat].value = stat_data.value # This was +=, but we're using signals
	elif stat_data.value > 0.0:
		print("adding new")
		stat_data.min_value = 0.0
		stat_datas[stat_data.stat] = stat_data
		stat_data_added.emit(stat_data)
	else:
		print("We couldn't fit")

func _real_changed(amount: int) -> void:
	print("Real Changed")
	var production_data: ProductionData = ProductionData.new()
	production_data.stat = REAL_STAT
	production_data.value = amount
	add_stat_data(production_data)

func _fake_changed(amount: int) -> void:
	var production_data: ProductionData = ProductionData.new()
	production_data.stat = FAKE_STAT
	production_data.value = amount
	add_stat_data(production_data)

func _stolen_changed(amount: int) -> void:
	var production_data: ProductionData = ProductionData.new()
	production_data.stat = STOLEN_STAT
	production_data.value = amount
	add_stat_data(production_data)
