extends VBoxContainer
class_name QuotaContainer

@onready var _report_number_label: Label = $HBoxContainer2/ReportNumberLabel
@onready var _quota_bar: ProgressBar = $HBoxContainer2/VBoxContainer/QuotaBar
@onready var _amount_label: Label = $HBoxContainer2/VBoxContainer/AmountLabel


var report_number: int:
	set(value):
		report_number = value
		_report_number_label.text = str(value)

func set_amount(value: int, max_value: int) -> void:
	_amount_label.text = "%s/%s" % [value, max_value]
