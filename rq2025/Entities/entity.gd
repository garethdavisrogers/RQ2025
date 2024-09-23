extends CharacterBody2D

# An entity is the primary active node type
# NPCs, Players, and Enemies are defined by the superclass entity

# Entities all have some constants
var type = null
var movedir = Vector2()
var knockdir = null
var spritedir = -1
var melee_speed = 50
var speed = 100
var max_speed = 200

# References to LevelManager and state
var level_manager
var targeted_player = null
var state
var health = 100
var roles
var states
var role
var is_getting_on_line = false
var is_attacking = false
var cooling_down = false
var current_attack_index = 1
var attack_index_is_even = false
var is_striking = false
var is_countering = false
# Entity onready vars
@onready var id = self.get_instance_id()
@onready var sprite = $Sprite2D
@onready var hit_box = $Sprite2D/Hitbox
@onready var anim = $Anim
@onready var cooldown_timer = $CoolDown
@onready var hit_collider = $Sprite2D/HitCollider

func state_machine(s):
	if state != s:
		state = s

func _ready():
	# Access LevelManager using an autoload reference or correct node path
	level_manager = get_node_or_null("/root/Level")
	states = level_manager.enums.states
	roles = level_manager.enums.roles
	state_machine(states.IDLE)
	cooldown_timer.wait_time = 0.2

# Movement logic
func movement_loop():
	if knockdir != null:
		velocity = (floor(speed / 2)) * knockdir
	elif state == states.ATTACK:
		velocity = melee_speed * movedir
	else:
		velocity = speed * movedir
	move_and_slide()

# Sprite direction logic
func spritedir_loop():
	if movedir.x < 0:
		sprite.scale.x = -abs(sprite.scale.x)
	elif movedir.x > 0:
		sprite.scale.x = abs(sprite.scale.x)

func anim_switch(new_anim):
	if anim.current_animation != new_anim:
		anim.play(new_anim)

func get_index_is_even():
	return current_attack_index % 2 == 0
	
func cooldown():
	cooling_down = true
	cooldown_timer.start()
	
func reset_non_attack_variables():
	current_attack_index = 1
	cooling_down = false
	is_attacking = false

func _on_cool_down_timeout():
	cooling_down = false

func _on_hitbox_area_entered(area):
	var attacker = area.get_parent().get_parent()
	if attacker and attacker.state != states.STAGGER:
		if state == states.ATTACK and not attacker.is_countering:
			if attack_index_is_even == attacker.attack_index_is_even:
				is_countering = true
		else:
			knockdir = global_position.direction_to(attacker.global_position) * -1
			if knockdir.x > 0:
				sprite.scale.x = -abs(sprite.scale.x)
			else:
				sprite.scale.x = abs(sprite.scale.x)
			var damage = attacker.current_attack_index
			health -= damage
			var stagger_ind = min(attacker.current_attack_index, 4)
			anim_switch(str("stagger_", stagger_ind))
			state_machine(states.STAGGER)


func _on_anim_animation_finished(anim_name):
	if anim_name.contains("die"):
		queue_free()
