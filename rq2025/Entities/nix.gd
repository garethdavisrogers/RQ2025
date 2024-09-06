extends "res://Entities/entity.gd"

func _ready():
	add_to_group("PLAYER")
	
func _physics_process(_delta):
	# Add the gravity.
	movement_loop()
	spritedir_loop()
	controls_loop()

func controls_loop():
	var LEFT = Input.is_action_pressed("ui_left")
	var RIGHT = Input.is_action_pressed("ui_right")
	var UP = Input.is_action_pressed("ui_up")
	var DOWN = Input.is_action_pressed("ui_down")
	
	movedir.x = -int(LEFT) + int(RIGHT)
	movedir.y = -int(UP) + int(DOWN)
	
	if movedir != Vector2.ZERO:
		movedir = movedir.normalized()
