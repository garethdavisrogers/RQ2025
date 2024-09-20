extends "res://Entities/entity.gd"

func _ready():
	add_to_group("PLAYER")
	super()
	type = level_manager.enums.types.PLAYER

func _physics_process(_delta):
	if state == states.DEAD:
		anim_switch("die")
	else:
		movement_loop()
		spritedir_loop()
		if state != states.STAGGER:
			controls_loop()
			knockdir = null
			if movedir == Vector2():
				anim_switch("idle")
			else:
				anim_switch("walk")


func controls_loop():
	var LEFT = Input.is_action_pressed("ui_left")
	var RIGHT = Input.is_action_pressed("ui_right")
	var UP = Input.is_action_pressed("ui_up")
	var DOWN = Input.is_action_pressed("ui_down")
	
	movedir.x = -int(LEFT) + int(RIGHT)
	movedir.y = -int(UP) + int(DOWN)
	
	if movedir != Vector2.ZERO:
		movedir = movedir.normalized()
		
	if Input.is_action_just_pressed("lite_attack"):
		pass
