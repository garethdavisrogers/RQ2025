extends "res://Entities/entity.gd"

var role = null

func _ready():
	add_to_group("ENEMY")
	super()

func _physics_process(_delta):
	movement_loop()
	spritedir_loop()
	target_player()
	
func target_player():
	var player_tracker = level_manager.player_tracker
	var player_keys = player_tracker.keys()
	var least_agro = level_manager.get_least_agro_players()
	
func get_closest_player():
	pass
