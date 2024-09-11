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
