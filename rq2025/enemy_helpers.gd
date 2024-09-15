extends Node

static func get_orthogonal_coefficient(direction_to_player):
	var below_player = direction_to_player.y <= 0
	var above_player = direction_to_player.y > 0
	var left_of_player = direction_to_player.x > 0
	var right_of_player = direction_to_player.x <= 0
	if below_player and left_of_player or above_player and right_of_player:
		return 1
	elif below_player and right_of_player or above_player and left_of_player:
		return -1

static func aggressor_is_same_side(aggressor_x_position, targeted_player_x_position, global_x_position):
	if min(aggressor_x_position, targeted_player_x_position, global_x_position) == targeted_player_x_position:
		return true
	if max(aggressor_x_position, targeted_player_x_position, global_x_position) == targeted_player_x_position:
		return true
	return false

static func get_closest_player(lm, global_position, player_ids):
	var closest_player = null
	var closest_distance = INF  # Start with a large number to compare distances
	for id in player_ids:
		var player_node = lm.get_player_instance(id)
		if player_node:  # Ensure the player node exists
			var distance = global_position.distance_to(lm.get_player_position(id))  # Calculate distance
			if distance < closest_distance:
				closest_distance = distance
				closest_player = player_node
	return closest_player

static func set_role(lm, pid, roles):
	var existing_roles = lm.get_player_assigned_enemies(pid)
	if existing_roles[roles.AGGRESSOR] == null:
		return roles.AGGRESSOR
	elif existing_roles[roles.FLANKER] == null:
		return roles.FLANKER
	elif existing_roles[roles.MINION] == null:
		return roles.MINION

static func face_player(x_direction_to_player):
	if x_direction_to_player < 0:
		return true
	elif x_direction_to_player >= 0:
		return false

static func targeted_player_is_under_attack(enemies, id):
	for e in enemies:
		var enemy_node = enemies[e]
		if enemy_node != null and enemy_node.id != id and enemy_node.is_attacking:
			return true
	return false
