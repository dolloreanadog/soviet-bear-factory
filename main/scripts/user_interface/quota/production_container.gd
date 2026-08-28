extends PanelContainer
class_name ProductionContainer


signal value_changed
@export var stat_data: ProductionData:
	set = set_stat_data
var tween: Tween
var minimum_size_tweener: PropertyTweener
var uv_scale_tweener: MethodTweener
var texture_rect_size_tweener: PropertyTweener
@onready var style_box: StyleBoxFlat = get_theme_stylebox(&"panel")
@onready var texture_rect: TextureRect = $Panel/CenterContainer/TextureRect
@onready var panel_stylebox: StyleBoxFlat = $Panel.get_theme_stylebox(&"panel")
@onready var panel_material: ShaderMaterial = $Panel.material


func _ready() -> void:
	if stat_data:
		_update_stat_data_dependencies()


func set_stat_data(_stat_data: ProductionData) -> void:
	stat_data = _stat_data
	if stat_data and texture_rect and style_box:
		_update_stat_data_dependencies()


func _update_stat_data_dependencies() -> void:
	texture_rect.texture = stat_data.stat.icon
	style_box.border_color = stat_data.stat.color
	panel_stylebox.bg_color = stat_data.stat.color
	set_material_thickness(stat_data.value / 20)
	stat_data.value_changed.connect(_on_stat_data_value_changed)
	_on_stat_data_value_changed()


func _on_stat_data_value_changed() -> void:
	if not stat_data:
		return
	if tween:
		tween.kill()
	if not stat_data.value <= 0.0:
		visible = true
	tween = create_tween()
	tween.set_parallel()
	minimum_size_tweener = tween.tween_property(
		self,
		^"custom_minimum_size",
		Vector2(max(0.0, stat_data.value), custom_minimum_size.y),
		0.5
	).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT).from_current()
	uv_scale_tweener = tween.tween_method(
		set_material_thickness,
		panel_material.get_shader_parameter("UVScale").x,
		stat_data.value / 20,
		0.5
	).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	if stat_data.value < texture_rect.texture.get_size().x \
		or texture_rect.custom_minimum_size.x < stat_data.value:
		texture_rect_size_tweener = tween.tween_property(
			texture_rect,
			^"custom_minimum_size",
			Vector2(max(0.0, stat_data.value), texture_rect.size.y),
			0.5
		).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT).from_current()
	tween.finished.connect(_on_tween_finished)


func set_material_thickness(value: float) -> void:
	panel_material.set_shader_parameter("UVScale", Vector2(value, panel_material.get_shader_parameter("UVScale").y))


func _on_tween_finished() -> void:
	if stat_data.value <= 0.0:
		visible = false
	value_changed.emit()
