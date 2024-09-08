extends Node2D

var player_tracker = {}

enum roles {
	AGGRESSOR,
	FLANKER,
	MINION
}

func _ready():
	set_players()

func set_players():
	player_tracker = {}
	var players = get_tree().get_nodes_in_group("PLAYER")
	for player in players:
		var player_id = str(player.get_instance_id())
		if not player_tracker.has(player_id):
			add_player(player)

func add_player(player_node):
	var player_key = player_node.get_instance_id()
	var player_values = {
		"node": player_node,
		"assignedEnemies": {
			roles.AGGRESSOR: null,
			roles.FLANKER: null,
			roles.MINION: null
			}
		}
	player_tracker[player_key] = player_values
	
func remove_player(player_node):
	var player_id = str(player_node.get_instance_id())
	player_tracker.erase(player_id)
	
func get_least_agro_players():
	var least_agro_players = []
	var least_agro_count = INF
	for key in player_tracker.keys():
		var assigned_enemies = player_tracker[key].assignedEnemies
		var player_agro_count = 0
		
		# Count only non-null assigned enemies
		for role in assigned_enemies.keys():
			if assigned_enemies[role] != null:
				player_agro_count += 1
		
		if player_agro_count < least_agro_count:
			least_agro_count = player_agro_count
			least_agro_players = [key]
		elif least_agro_count == player_agro_count:
			least_agro_players.append(key)
	return least_agro_players

func update_assigned_enemies(pid, e, enemy_role):
	var assigned_enemies = player_tracker[pid].assignedEnemies
	assigned_enemies[enemy_role] = e
