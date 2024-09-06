extends "res://Entities/entity.gd"

var targeted_player_id = null
var role = null
var is_in_melee_range = false
var roles

func _ready():
	add_to_group("ENEMY")
	super()
	roles = level_manager.enemy_roles

func _physics_process(_delta):
	if state == states.DEAD:
		queue_free()
	else:
		if targeted_player_id == null:
			state_machine(states.IDLE)
			target_player()
		elif not is_in_melee_range:
			state_machine(states.SEEK)
		if state == states.SEEK:
			movement_loop()
			spritedir_loop()

func target_player():
	var player_tracker = level_manager.player_tracker
	var least_agro_players = level_manager.get_least_agro_players()
	get_closest_player(least_agro_players, player_tracker)
	
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
		set_role(pt)

func set_role(pt):
	var existing_roles = pt[targeted_player_id].assignedEnemies
	if existing_roles.size() == 0:
		role = roles.AGGRESSOR
	elif existing_roles.size() == 1:
		role = roles.FLANKER
	elif existing_roles.size() == 2:
		role = roles.MINION
	level_manager.update_assigned_enemies(targeted_player_id, self.get_instance_id(), role)
