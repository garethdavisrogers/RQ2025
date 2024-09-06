extends Node2D

var player_tracker = {}

func _ready():
	set_players()

func set_players():
	var players = get_tree().get_nodes_in_group("PLAYER")
	for player in players:
		var player_id = str(player.get_instance_id())
		if not player_tracker.has(player_id):
			add_player(player)

func add_player(player_node):
	var player_key = player_node.get_instance_id()
	var player_values = {
		"node": player_node,
		"assignedEnemies": {}
		}
	player_tracker[player_key] = player_values
	
func remove_player(player_node):
	var player_id = str(player_node.get_instance_id())
	player_tracker.erase(player_id)

func get_least_agro_players():
	var least_agro_players = []
	var player_keys = player_tracker.keys()
	var least_agro_count = null
	for key in player_keys:
		var number_of_assigned_enemies = player_tracker[key].assignedEnemies.size()
		if least_agro_count == null or number_of_assigned_enemies < least_agro_count:
			least_agro_count = number_of_assigned_enemies
			least_agro_players = []
			least_agro_players.append(key)
		elif least_agro_count == number_of_assigned_enemies:
			least_agro_players.append(key)
	return least_agro_players
		
