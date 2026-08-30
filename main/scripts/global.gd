extends Node

const MAIN_GAME = preload("uid://xjgfc17crloh")
const MAIN_MENU = preload("uid://xwnj4nnggtky")

const SEIZETHEMEANS_PORTAITS_BUNNY = preload("uid://civgpmeo55ksu")
const SEIZETHEMEANS_PORTAITS_FOX = preload("uid://c2ltjkjibfh7f")
const SEIZETHEMEANS_PORTAITS_SEAL = preload("uid://b70iepkvglyj2")

## What the player can become
enum AvatarSelection {BUNNY, FOX, SEAL}

# TODO: This can be what they choose to be
var avatar_selected: Texture


## The agreed name the player wants
var player_name: String = "Player"

func _ready() -> void:
	var textures: Array[Texture] = [SEIZETHEMEANS_PORTAITS_BUNNY, SEIZETHEMEANS_PORTAITS_FOX, SEIZETHEMEANS_PORTAITS_SEAL]
	avatar_selected = textures.pick_random()

func go_to_game() -> void:
	var level: MainGame = MAIN_GAME.instantiate()
	get_tree().root.add_child(level)
	#get_tree().change_scene_to_packed(MAIN_GAME)


func go_to_main_menu() -> void:
	var level: MainMenu = MAIN_MENU.instantiate()
	get_tree().root.add_child(level)
	#get_tree().change_scene_to_packed(MAIN_MENU)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Exit"):
		get_tree().quit()
