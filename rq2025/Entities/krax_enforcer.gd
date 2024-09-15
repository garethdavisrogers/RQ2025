extends "res://Entities/entity.gd"

const ENGAGEMENT_THRESHOLD = 200
const ATTACK_THRESHOLD = 150
const MINION_ATTACK_THRESHOLD = 180
const MELEE_THRESHOLD = 120
var enemy_helpers = load("res://enemy_helpers.gd")
var targeted_player_id
var distance_to_targeted_player
var is_attacking = false

@onready var attack_timer = $AttackTimer

func _ready():
	add_to_group("ENEMY")
	super()
	type = level_manager.enums.types.ENEMY
	attack_timer.wait_time = 3

func _physics_process(_delta):
	if targeted_player_id == null:
		state_machine(states.IDLE)
	else:
		distance_to_targeted_player = get_distance_to_targeted_player()
		if not get_is_on_line():
			is_getting_on_line = true
		
		movement_loop()
		face_player()
		set_is_on_line()
		
		if distance_to_targeted_player > ENGAGEMENT_THRESHOLD:
			state_machine(states.SEEK)
		elif distance_to_targeted_player > ATTACK_THRESHOLD or is_getting_on_line:
			state_machine(states.ENGAGE)
		else:
			state_machine(states.ATTACK)
	match state:
		states.IDLE:
			target_player(level_manager)
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
		set_role(targeted_player_id)

func set_role(pid):
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
			movedir += get_direction_to_targeted_player() * -1
	elif distance_to_targeted_player > ATTACK_THRESHOLD:
			approach()

func flank():
	var player_direction = get_direction_to_targeted_player()
	var orthogonal_direction = get_orthogonal_direction()
	if aggressor_is_same_side():
		is_getting_on_line = true
		orthogonal_direction *= -1
	movedir = orthogonal_direction.normalized()
	if distance_to_targeted_player < ATTACK_THRESHOLD:
		movedir += get_direction_to_targeted_player() * -1
	elif not is_getting_on_line:
		approach()
			
func bolster():
	if is_getting_on_line:
		movedir = get_orthogonal_direction()
		var player_direction = get_direction_to_targeted_player()
		if distance_to_targeted_player < MINION_ATTACK_THRESHOLD:
			movedir += player_direction * -1
	elif distance_to_targeted_player > MINION_ATTACK_THRESHOLD:
			approach()
		
func attack():
	if role == roles.AGGRESSOR or role == roles.FLANKER:
		var x_direction_to_targeted_player = get_direction_to_targeted_player().x
		if distance_to_targeted_player > MELEE_THRESHOLD:
			movedir = Vector2(x_direction_to_targeted_player, 0)
		elif distance_to_targeted_player < 80:
			movedir = Vector2(-x_direction_to_targeted_player, 0)
		var player_is_being_attacked = enemy_helpers.targeted_player_is_under_attack(get_targeted_player_assigned_enemies())
		if not cooling_down and not player_is_being_attacked:
			is_attacking = true
			lite_attack()

func lite_attack():
	if current_attack_index < 3:
		anim_switch(str("lite_attack_", current_attack_index))
		cooldown()
	else:
		attack_timer.start()
		cooling_down = true
		is_attacking = false
		current_attack_index = 1
		anim_switch("walk")
			
	
func get_orthogonal_direction():
	var orthogonal_coefficient = get_orthogonal_coefficient()
	return get_direction_to_targeted_player().orthogonal() * orthogonal_coefficient
	
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
	sprite.flip_h = enemy_helpers.face_player(x_direction_to_player)


func _on_anim_animation_finished(anim_name):
	if anim_name.contains("lite_attack"):
		current_attack_index += 1


func _on_attack_timer_timeout():
	cooling_down = false
