extends "res://Entities/entity.gd"

const ENGAGEMENT_THRESHOLD = 300
const ATTACK_THRESHOLD = 120
var targeted_player_id

func _ready():
	add_to_group("ENEMY")
	super()

func _physics_process(_delta):
	if targeted_player_id == null:
		state_machine(states.IDLE)
	else:
		var distance_to_player = get_distance_to_targeted_player()
		
		if not get_is_on_line():
			is_getting_on_line = true
		set_is_on_line()
		movement_loop()
		spritedir_loop()
		
		if distance_to_player > ENGAGEMENT_THRESHOLD:
			state_machine(states.SEEK)
		elif distance_to_player > ATTACK_THRESHOLD or is_getting_on_line:
			state_machine(states.ENGAGE)
		else:
			state_machine(states.ATTACK)
	match state:
		states.IDLE:
			target_player()
		states.SEEK:
			seek()
		states.ENGAGE:
			engage()
		states.ATTACK:
			movedir = Vector2()
				
func target_player():
	var least_agro_players = level_manager.get_least_agro_players()
	get_closest_player(least_agro_players)
	
func get_closest_player(player_ids):
	var closest_player = null
	var closest_distance = INF  # Start with a large number to compare distances
	for id in player_ids:
		var player_node = level_manager.get_player_instance(id)
		if player_node:  # Ensure the player node exists
			var distance = global_position.distance_to(level_manager.get_player_position(id))  # Calculate distance
			if distance < closest_distance:
				closest_distance = distance
				closest_player = player_node
				
	# Update targeted_player_id with the closest player
	if closest_player != null:
		targeted_player_id = closest_player.id
		set_role(targeted_player_id)

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
	approach()
	
func engage():
	if role == roles.AGGRESSOR:
		aggress()
	elif role == roles.FLANKER:
		flank()
	else:
		pass
		
func flank():
	var distance_to_player = get_distance_to_targeted_player()
	if aggressor_is_same_side() or is_getting_on_line:
		var orthogonal_coefficient = get_orthogonal_coefficient()
		var player_direction = get_direction_to_targeted_player()
		var orthogonal_direction = get_direction_to_targeted_player().orthogonal() * orthogonal_coefficient
		movedir = orthogonal_direction
		if distance_to_player < ATTACK_THRESHOLD:
			movedir += player_direction * -1
	elif distance_to_player > ATTACK_THRESHOLD:
			approach()
	else:
		state_machine(states.ATTACK)

func aggress():
	var distance_to_player = get_distance_to_targeted_player()
	if is_getting_on_line:
		var orthogonal_coefficient = get_orthogonal_coefficient()
		var player_direction = get_direction_to_targeted_player()
		var orthogonal_direction = get_direction_to_targeted_player().orthogonal() * orthogonal_coefficient
		movedir = orthogonal_direction
		if distance_to_player < ATTACK_THRESHOLD:
			movedir += player_direction * -1
	elif distance_to_player > ATTACK_THRESHOLD:
			approach()
	else:
		state_machine(states.ATTACK)
	
func get_distance_to_targeted_player():
	return global_position.distance_to(get_targeted_player_position())
	
func get_direction_to_targeted_player():
	return global_position.direction_to(get_targeted_player_position())

func get_targeted_player_position():
	return level_manager.get_player_position(targeted_player_id)
	
func get_targeted_player_assigned_enemies():
	return level_manager.get_player_assigned_enemies(targeted_player_id)
	
func get_on_line_coefficient():
	var targeted_player_position = get_targeted_player_position()
	var y_movedir = null
	if global_position.y < targeted_player_position.y:
		y_movedir = 1
	elif global_position.y > targeted_player_position.y:
		y_movedir = -1
	return y_movedir
		
func get_is_on_line():
	return abs(global_position.y - get_targeted_player_position().y) < 20
	
func set_is_on_line():
	if abs(global_position.y - get_targeted_player_position().y) < 1:
		is_getting_on_line = false
	
func get_orthogonal_coefficient():
	var direction_to_player = get_direction_to_targeted_player()
	var below_player = direction_to_player.y <= 0
	var above_player = direction_to_player.y > 0
	var left_of_player = direction_to_player.x > 0
	var right_of_player = direction_to_player.x <= 0
	if below_player and left_of_player or above_player and right_of_player:
		return 1
	elif below_player and right_of_player or above_player and left_of_player:
		return -1

func adjust_distance():
	var player_position = get_targeted_player_position()
	var direction_away_from_player = player_position.direction_to(global_position)
	movedir.x = direction_away_from_player.x

func aggressor_is_same_side():
	var aggressor_x_position = get_targeted_player_assigned_enemies()[roles.AGGRESSOR].position.x
	var targeted_player_x_position = get_targeted_player_position().x
	if min(aggressor_x_position, targeted_player_x_position, global_position.x) == targeted_player_x_position:
		return true
	if max(aggressor_x_position, targeted_player_x_position, global_position.x) == targeted_player_x_position:
		return true
	return false
	
func approach():
	movedir = global_position.direction_to(get_targeted_player_position())

	
