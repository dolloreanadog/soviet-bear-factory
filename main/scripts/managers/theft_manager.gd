extends Node
class_name TheftManager

@export var steal_amount_per_point: int = 100

signal on_loss()


# TODO: If a player dies, they should no longer be able to steal from them, remove it from theft_dictionary

# Either this or get_multiplayer_authority
var owner_id: int 

## Player ID, theft amount. Who and how much they're stealing from you
var loss_dictionary: Dictionary[int, int]
## Player ID, theft amount. Who and how much you're stealing from others
var theft_dictionary: Dictionary[int, int]

func steal(player_id: int) -> void:
	if theft_dictionary.has(player_id):
		theft_dictionary[player_id] += steal_amount_per_point
	else:
		theft_dictionary[player_id] = steal_amount_per_point
	
	for Player: FactoryView in Global.Get_Players(): # This will eventually have stalin as well
		Player.theft_manager.lose(owner_id)

## Add it to the loss dictionary
func lose(player_id: int) -> void:
	if loss_dictionary.has(player_id):
		loss_dictionary[player_id] += steal_amount_per_point
	else:
		loss_dictionary[player_id] = steal_amount_per_point
	
	on_loss.emit()

## See how much they've stolen in total
func get_amount_stolen() -> int:
	var total: int = 0
	
	
	for id: int in theft_dictionary:
		total = theft_dictionary[id]
	
	return total

func get_amount_lost() -> int:
	var total: int = 0
	
	for id: int in loss_dictionary:
		total = loss_dictionary[id]
	
	return total

func return_stolen() -> void:
	for Player: Node in Global.Get_Players():
		pass
