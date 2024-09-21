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
		index_is_even = get_index_is_even()
		
		if state != states.STAGGER:
			knockdir = null
			controls_loop()
		
			if state != states.ATTACK:
				reset_non_attack_variables()
				if movedir == Vector2():
					anim_switch("idle")
				else:
					anim_switch("walk")
	
	match state:
		states.ATTACK:
			pass

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
		state_machine(states.ATTACK)
		if current_attack_index < 3 and not cooling_down:
			anim_switch(str("lite_attack_", current_attack_index))
			current_attack_index += 1
		cooldown()

func _on_anim_animation_finished(anim_name):
	super(anim_name)
	if anim_name.contains("lite_attack"):
		cooling_down = false
		state_machine(states.IDLE)
