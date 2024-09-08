extends CharacterBody2D

# An entity is the primary active node type
# NPCs, Players, and Enemies are defined by the superclass entity

# Entities all have some constants
var type = null
var movedir = Vector2()
var spritedir = -1
var speed = 100
var max_speed = 200

# References to LevelManager and state
var level_manager
var enums
var targeted_player = null
var state
var is_dead = true
var roles
var states
var role
var is_on_line = false

# Entity onready vars
@onready var id = self.get_instance_id()
@onready var sprite = $Sprite2D
@onready var hit_box = $Hitbox
@onready var anim = $Anim

func state_machine(s):
	if state != s:
		state = s

func _ready():
	# Access LevelManager using an autoload reference or correct node path
	level_manager = get_node_or_null("/root/Level")
	enums = level_manager.enums
	is_dead = false
	states = enums.states
	roles = enums.roles
	state_machine(states.IDLE)

# Movement logic
func movement_loop():
	velocity = speed * movedir
	move_and_slide()

# Sprite direction logic
func spritedir_loop():
	if movedir.x < 0:
		spritedir = -1
	elif movedir.x > 0:
		spritedir = 1
	scale.x = scale.y * spritedir
