extends "res://Entities/entity.gd"

var targeted_player_id = null

func _ready():
	add_to_group("ENEMY")
	super()

func _physics_process(_delta):
	if state == states.DEAD:
		queue_free()
	else:
		if targeted_player_id == null:
			state_machine(states.IDLE)
			target_player()
		else:
			get_distance_to_player()
			movement_loop()
			spritedir_loop()
			if state == states.SEEK:
				seek()
			elif state == states.ENGAGE:
				engage()
			elif state == states.ATTACK:
				movedir = Vector2()

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
	if existing_roles[roles.AGGRESSOR] == null:
		role = roles.AGGRESSOR
	elif existing_roles[roles.FLANKER] == null:
		role = roles.FLANKER
	elif existing_roles[roles.MINION] == null:
		role = roles.MINION
	level_manager.update_assigned_enemies(targeted_player_id, self, role)

func seek():
	var player_position = get_targeted_player_position()
	movedir = global_position.direction_to(player_position)

func engage():
	if role == roles.FLANKER:
		flank()
	else:
		get_on_line()
	
func get_distance_to_player():
	var player_position = get_targeted_player_position()
	var distance_from_player = global_position.distance_to(player_position)
	if distance_from_player > 500:
		state_machine(states.SEEK)
	elif distance_from_player > 200:
		state_machine(states.ENGAGE)
	else:
		state_machine(states.ATTACK)

func get_targeted_player_position():
	return level_manager.player_tracker[targeted_player_id].node.global_position
	
func get_targeted_player_assigned_enemies():
	return level_manager.player_tracker[targeted_player_id].assignedEnemies
	
func get_on_line():
	var player_position = get_targeted_player_position()
	if abs(player_position.y) - abs(global_position.y) > 100:
		if player_position.y < global_position.y:
			movedir = Vector2(-1, 0)
		elif player_position.y > global_position.y:
			movedir = Vector2(1, 0)

func flank():
	var assigned_enemies = get_targeted_player_assigned_enemies()
	var targeted_player = level_manager.player_tracker[targeted_player_id]
	var aggressor_position = targeted_player.assignedEnemies[roles.AGGRESSOR].global_position
	var flank_radius = 300

	var player_position = get_targeted_player_position()
	var direction_to_player = global_position.direction_to(player_position)
	var distance_to_player = global_position.distance_to(player_position)

	# Calculate the difference in position to maintain the radius
	var target_position = player_position + (direction_to_player * flank_radius)

	# Adjust the flanker movement if it's too close to the player
	if distance_to_player < flank_radius:
		movedir = (global_position - player_position).normalized() * flank_radius
	else:
		# Check which side of the player the aggressor is on, and move to the opposite side
		if (global_position.x < player_position.x and aggressor_position.x < player_position.x) or (global_position.x > player_position.x and aggressor_position.x > player_position.x):
			if player_position.y < global_position.y:
				movedir = Vector2(-direction_to_player.y, direction_to_player.x).normalized()
			else:
				movedir = Vector2(direction_to_player.y, -direction_to_player.x).normalized()
		else:
			movedir = direction_to_player
