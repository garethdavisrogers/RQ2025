extends Node2D

var statics = load("res://statics.gd")
var roles = statics.roles
var player_tracker = {}

func _ready():
	set_players()

func get_players():
	return get_tree().get_nodes_in_group("PLAYER")
	
func get_player_instance(pid):
	return player_tracker[pid].instance
	
func get_player_assigned_enemies(pid):
	return player_tracker[pid].assignedEnemies
	
func set_players():
	var players = get_players()
	player_tracker = {}
	for player in players:
		if not player_tracker.has(player.id):
			add_player(player)

func add_player(player_instance):
	var player_key = player_instance.id
	var player_values = {
		"instance": player_instance,
		"assignedEnemies": {
			roles.AGGRESSOR: null,
			roles.FLANKER: null,
			roles.MINION: null,
			roles.SNIPER: null,
			roles.JACKAL: null
			}
		}
	player_tracker[player_key] = player_values
	
func remove_player(player_node):
	player_tracker.erase(player_node.id)
	
func get_least_agro_players():
	var least_agro_players = []
	var least_agro_count = INF
	for key in player_tracker.keys():
		var assigned_enemies = get_player_assigned_enemies(key)
		var player_agro_count = 0
		
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
