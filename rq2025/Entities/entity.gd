extends CharacterBody2D

# An entity is the primary active node type
# NPCs, Players, and Enemies are defined by the superclass entity

# Entities all have some constants
var type = null
var movedir = Vector2()
var spritedir = -1
var melee_speed = 50
var speed = 100
var max_speed = 200

# References to LevelManager and state
var level_manager
var targeted_player = null
var state
var is_dead = true
var roles
var states
var role
var is_getting_on_line = false
var cooling_down = false
var current_attack_index = 1
# Entity onready vars
@onready var id = self.get_instance_id()
@onready var sprite = $Sprite2D
@onready var hit_box = $Hitbox
@onready var anim = $Anim
@onready var cooldown_timer = $CoolDown
@onready var hit_collider = $HitCollider

func state_machine(s):
	if state != s:
		state = s

func _ready():
	# Access LevelManager using an autoload reference or correct node path
	level_manager = get_node_or_null("/root/Level")
	is_dead = false
	states = level_manager.enums.states
	roles = level_manager.enums.roles
	state_machine(states.IDLE)
	cooldown_timer.wait_time = 0.8

# Movement logic
func movement_loop():
	if state == states.ATTACK:
		velocity = melee_speed * movedir
	else:
		velocity = speed * movedir
	move_and_slide()

# Sprite direction logic
func spritedir_loop():
	if movedir.x < 0:
		sprite.flip_h = true
	elif movedir.x > 0:
		sprite.flip_h = false

func anim_switch(new_anim):
	if anim.is_playing() and anim.current_animation == new_anim:
		return
	anim.play(new_anim)

func cooldown():
	cooling_down = true
	cooldown_timer.start()

func _on_hitbox_area_entered(area):
	var attacker = area.get_overlapping_areas()

func _on_cool_down_timeout():
	cooling_down = false
