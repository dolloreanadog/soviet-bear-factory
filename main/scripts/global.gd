extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Exit"):
		get_tree().quit()

## Will be in game manager, but here for now
func Get_Players() -> Array:
	var array: Array
	
	#
	
	return array
