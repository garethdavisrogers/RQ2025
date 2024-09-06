extends "res://Entities/entity.gd"

var targeted_player_id = null
var role = null

func _ready():
	add_to_group("ENEMY")
	super()

func _physics_process(_delta):
	movement_loop()
	spritedir_loop()
	if targeted_player_id == null:
		target_player()
	
func target_player():
	var player_tracker = level_manager.player_tracker
	var player_keys = player_tracker.keys()
	var least_agro = level_manager.get_least_agro_players()
	get_closest_player(least_agro, player_tracker)
	
func get_closest_player(player_ids, pt):
	var closest_player = null
	var closest_distance = INF  # Start with a large number to compare distances
	for id in player_ids:
		var player_node = pt[id].node
		if player_node:  # Ensure the player node exists
			var distance = global_position.distance_to(player_node.global_position)  # Calculate distance
			if distance < closest_distance:
				closest_distance = distance
				closest_player = player_node
				
	# Update targeted_player_id with the closest player
	if closest_player != null:
		targeted_player_id = closest_player.get_instance_id()
