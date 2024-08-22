extends "res://Entities/entity.gd"

func controls_loop():
	var CENTER = Vector2(0, 0)
	var LEFT = Vector2(-1, 0)
	var RIGHT = Vector2(1, 0)
	var UP = Vector2(0, -1)
	var DOWN = Vector2(0, 1)
	
	var unnormalized_movedir = CENTER
	
	if Input.is_action_pressed("move_left"):
		unnormalized_movedir += LEFT
	if Input.is_action_pressed("move_right"):
		unnormalized_movedir += RIGHT
	if Input.is_action_pressed("move_up"):
		unnormalized_movedir += UP
	if Input.is_action_pressed("move_down"):
		unnormalized_movedir += DOWN
	else:
		unnormalized_movedir = CENTER
	
	movedir = unnormalized_movedir.normalized()
