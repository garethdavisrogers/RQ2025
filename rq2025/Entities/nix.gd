extends "res://Entities/entity.gd"

func _ready():
	add_to_group("PLAYER")
	super()
	type = level_manager.enums.types.PLAYER

func _physics_process(_delta):
	movement_loop()
	if state != states.STAGGER:
		knockdir = null
		if movedir == Vector2():
			anim_switch("idle")
		else:
			anim_switch("walk")
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

func _on_anim_animation_finished(anim_name):
	if anim_name.contains("stagger"):
		knockdir = null
		state_machine(states.IDLE)
