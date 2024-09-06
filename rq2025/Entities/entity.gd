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
var target_player = null
var current_state = states.IDLE

# Entity onready vars
@onready var sprite = $Sprite2D
@onready var hit_box = $Hitbox
@onready var anim = $Anim

enum states {
	IDLE,
	MOVING,
	ATTACKING
}

func _ready():
	# Access LevelManager using an autoload reference or correct node path
	level_manager = get_node("/root/Level")  # Adjust this path if LevelManager is not autoload
	
	# Ensure level_manager is valid
	if level_manager == null:
		print("LevelManager not found!")
		return
	
	# Register this entity with the LevelManager

func _physics_process(_delta):
	# Check if level_manager is valid before using it
	if level_manager != null:
		print(level_manager.players)
	
	movement_loop()
	spritedir_loop()

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
