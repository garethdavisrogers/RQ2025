extends "res://Entities/entity.gd"

const ENGAGEMENT_THRESHOLD = 300
const ATTACK_THRESHOLD = 200
const MINION_ATTACK_THRESHOLD = 250
const MELEE_THRESHOLD = 80
var enemy_helpers = load("res://enemy_helpers.gd")
var targeted_player_id
var distance_to_targeted_player
var direction_to_targeted_player

@onready var shuffle_timer = $ShuffleTimer

func _ready():
	add_to_group("ENEMY")
	super()
	type = level_manager.enums.types.ENEMY
	shuffle_timer.wait_time = 3

func _physics_process(_delta):
	if state == states.DEAD:
		anim_switch("die")
	else:
		if targeted_player_id == null:
			target_player(level_manager)
		else:
			distance_to_targeted_player = get_distance_to_targeted_player()
			direction_to_targeted_player = get_direction_to_targeted_player()
			attack_index_is_even = get_index_is_even()
			if not get_is_on_line():
				is_getting_on_line = true
			movement_loop()
			face_player()
			set_is_on_line()
			
			
			if state != states.STAGGER:
				knockdir = null
				if distance_to_targeted_player > ENGAGEMENT_THRESHOLD:
					state_machine(states.SEEK)
				elif distance_to_targeted_player > ATTACK_THRESHOLD or is_getting_on_line:
					state_machine(states.ENGAGE)
				else:
					state_machine(states.ATTACK)
					
				if state != states.ATTACK:
					reset_non_attack_variables()
					
		match state:
			states.IDLE:
				anim_switch("idle")
			states.SEEK:
				seek()
				anim_switch("walk")
			states.ENGAGE:
				engage()
			states.ATTACK:
				attack()
				
func target_player(lm):
	var least_agro_players = lm.get_least_agro_players()
	get_closest_player(least_agro_players)
	
func get_closest_player(player_ids):
	var closest_player = enemy_helpers.get_closest_player(level_manager, global_position, player_ids)
	if closest_player != null:
		targeted_player_id = closest_player.id
		set_role()
	else:
		state_machine(states.IDLE)

func set_role():
	role = enemy_helpers.set_role(level_manager, targeted_player_id, roles)
	level_manager.update_assigned_enemies(targeted_player_id, self, role)

func seek():
	cooling_down = false
	approach()
	
func engage():
	is_attacking = false
	current_attack_index = 1
	anim_switch("walk")
	if role == roles.AGGRESSOR:
		aggress()
	elif role == roles.FLANKER:
		flank()
	elif role == roles.MINION:
		bolster()
	else:
		pass

func aggress():
	if is_getting_on_line:
		movedir = get_orthogonal_direction()
		if distance_to_targeted_player < ATTACK_THRESHOLD:
			movedir += direction_to_targeted_player * -1
	elif distance_to_targeted_player > ATTACK_THRESHOLD:
			approach()

func flank():
	var orthogonal_direction = get_orthogonal_direction()
	if aggressor_is_same_side():
		is_getting_on_line = true
		orthogonal_direction *= -1
	movedir = orthogonal_direction.normalized()
	if distance_to_targeted_player < ATTACK_THRESHOLD:
		movedir += direction_to_targeted_player * -1
	elif not is_getting_on_line:
		approach()
			
func bolster():
	if is_getting_on_line:
		movedir = get_orthogonal_direction()
		if distance_to_targeted_player < MINION_ATTACK_THRESHOLD:
			movedir += direction_to_targeted_player * -1
	elif distance_to_targeted_player > MINION_ATTACK_THRESHOLD:
			approach()
		
func attack():
	var player_is_being_attacked = enemy_helpers.targeted_player_is_under_attack(get_targeted_player_assigned_enemies(), id)
	var x_direction_to_targeted_player = direction_to_targeted_player.x
	if player_is_being_attacked:
		is_attacking = false
		if role == roles.AGGRESSOR or role == roles.FLANKER:
			shuffle(ATTACK_THRESHOLD, MELEE_THRESHOLD)
		elif role == roles.MINION:
			shuffle(MINION_ATTACK_THRESHOLD, MELEE_THRESHOLD)
	else:
		is_attacking = true
		if distance_to_targeted_player > MELEE_THRESHOLD - 5:
			movedir = Vector2(x_direction_to_targeted_player, 0)
		elif not cooling_down:
			movedir = Vector2()
			lite_attack()

func shuffle(attack_threshold, melee_threshold):
	var x_direction_to_targeted_player = direction_to_targeted_player.x
	if distance_to_targeted_player > attack_threshold - 10:
		movedir = Vector2(x_direction_to_targeted_player, 0)
	elif distance_to_targeted_player < melee_threshold + 50:
		movedir = Vector2(-x_direction_to_targeted_player, 0)
	
func lite_attack():
	if current_attack_index > 4:
		is_attacking = false
		is_striking = false
		is_countering = false
		shuffle_timer.start()
		current_attack_index = 1
		anim_switch("walk")
	elif not cooling_down:
		anim_switch(str("lite_attack_", current_attack_index))
		is_striking = true
		current_attack_index += 1
		cooling_down = true
	
func get_orthogonal_direction():
	var orthogonal_coefficient = get_orthogonal_coefficient()
	return direction_to_targeted_player.orthogonal() * orthogonal_coefficient
	
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
	return enemy_helpers.get_orthogonal_coefficient(get_direction_to_targeted_player())

func adjust_distance():
	var player_position = get_targeted_player_position()
	var direction_away_from_player = player_position.direction_to(global_position)
	movedir.x = direction_away_from_player.x

func aggressor_is_same_side():
	var aggressor_x_position = get_targeted_player_assigned_enemies()[roles.AGGRESSOR].position.x
	var targeted_player_x_position = get_targeted_player_position().x
	return enemy_helpers.aggressor_is_same_side(aggressor_x_position, targeted_player_x_position, global_position.x)
	
func approach():
	movedir = get_direction_to_targeted_player()

func face_player():
	var x_direction_to_player = get_direction_to_targeted_player().x
	if x_direction_to_player < 0:
		sprite.scale.x = -abs(sprite.scale.x)
	else:
		sprite.scale.x = abs(sprite.scale.x)

func _on_shuffle_timer_timeout():
	cooling_down = false
	
func _on_anim_animation_finished(anim_name):
	super(anim_name)
	if anim_name.contains("lite_attack"):
		cooling_down = false
	if anim_name.contains("stagger"):
		cooling_down = false
		state_machine(states.ATTACK)
