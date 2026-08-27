extends Panel
class_name BottomUIPanel

@onready var text_chat_panel: TextChatPanel = $TextChatPanel
@onready var ruble_label: Label = $RublePanel/RubleLabel
@onready var report_time_label: Label = $QuotaPanel/ReportTimeLabel

func _update_ruble(amount: int) -> void:
	ruble_label.text = "₽%s" % [str(amount)]

@rpc("any_peer", "call_local", "reliable")
func new_report_time(time: int) -> void:
	report_time_label.text = "%ss" % [str(time)]

func _update_report_time(time: int) -> void:
	if NetworkManager.is_host:
		new_report_time.rpc(time)
