extends "res://Entities/entity.gd"

const ENGAGEMENT_THRESHOLD = 250
const ATTACK_THRESHOLD = 100
var targeted_player_id

func _ready():
	add_to_group("ENEMY")
	super()

func _physics_process(_delta):
	if targeted_player_id == null:
		state_machine(states.IDLE)
		target_player()
	else:
		var distance_from_player = get_distance_to_player()
		movement_loop()
		spritedir_loop()
		if distance_from_player > ENGAGEMENT_THRESHOLD:
			state_machine(states.SEEK)
			seek()
		elif distance_from_player > ATTACK_THRESHOLD:
			state_machine(states.ENGAGE)
			engage()
		elif distance_from_player <= ATTACK_THRESHOLD:
			state_machine(states.ATTACK)
			movedir = Vector2()

func target_player():
	var least_agro_players = level_manager.get_least_agro_players()
	get_closest_player(least_agro_players, level_manager.player_tracker)
	
func get_closest_player(player_ids, pt):
	var closest_player = null
	var closest_distance = INF  # Start with a large number to compare distances
	for id in player_ids:
		var player_node = pt[id].instance
		if player_node:  # Ensure the player node exists
			var distance = global_position.distance_to(player_node.global_position)  # Calculate distance
			if distance < closest_distance:
				closest_distance = distance
				closest_player = player_node
				
	# Update targeted_player_id with the closest player
	if closest_player != null:
		targeted_player_id = closest_player.id
		set_role(targeted_player_id)
		
func get_is_on_line():
	return abs(global_position.y - get_targeted_player_position().y) < 20

func set_role(pid):
	var existing_roles = level_manager.get_player_assigned_enemies(pid)
	if existing_roles[roles.AGGRESSOR] == null:
		role = roles.AGGRESSOR
	elif existing_roles[roles.FLANKER] == null:
		role = roles.FLANKER
	elif existing_roles[roles.MINION] == null:
		role = roles.MINION
	level_manager.update_assigned_enemies(targeted_player_id, self, role)

func seek():
	movedir = global_position.direction_to(get_targeted_player_position())

func engage():
	if role == roles.AGGRESSOR:
		aggress()
	if role == roles.FLANKER:
		if aggressor_is_same_side():
			flank()
		else:
			aggress()
	
func get_distance_to_player():
	var distance_from_player = global_position.distance_to(get_targeted_player_position())
	return distance_from_player

func get_targeted_player_position():
	return level_manager.get_player_position(targeted_player_id)
	
func get_targeted_player_assigned_enemies():
	return level_manager.get_player_assigned_enemies(targeted_player_id)
	
func get_on_line(tpp):
	if global_position.y < tpp.y:
		movedir.y = 1
	elif global_position.y > tpp.y:
		movedir.y = -1

func adjust_distance():
	var player_position = get_targeted_player_position()
	var direction_away_from_player = player_position.direction_to(global_position)
	movedir.x = direction_away_from_player.x

func aggress():
	get_on_line(get_targeted_player_position())
	adjust_distance()
	
func flank():
	var player_position = get_targeted_player_position()
	
	# Calculate the direction to the player
	var direction_to_player = global_position.direction_to(player_position)
	
	# Get the orthogonal (perpendicular) vector to the direction (to orbit)
	var perpendicular_vector = direction_to_player.orthogonal().normalized()
	
	
	if aggressor_is_same_side():
		# Move perpendicular to the player (orbit around the player)
		movedir = perpendicular_vector
	else:
		# If on the opposite side, reposition smoothly to the other side
		# You can use an interpolation to smooth the transition
		var target_position = player_position + Vector2(ENGAGEMENT_THRESHOLD * perpendicular_vector.x, ENGAGEMENT_THRESHOLD * perpendicular_vector.y)
		
		# Gradually move toward the target position
		movedir = (target_position - global_position).normalized()

func aggressor_is_same_side():
	var aggressor_x_position = get_targeted_player_assigned_enemies()[roles.AGGRESSOR].position.x
	var targeted_player_x_position = get_targeted_player_position().x
	if min(aggressor_x_position, targeted_player_x_position, global_position.x) == targeted_player_x_position:
		return true
	if max(aggressor_x_position, targeted_player_x_position, global_position.x) == targeted_player_x_position:
		return true
		
	return false
	
