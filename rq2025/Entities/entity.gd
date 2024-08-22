extends CharacterBody2D

# An entity is the primary active node type
# NPCs, Players, and Enemies are defined by the superclass entity

# Entities all have some constants

var health = 0
var is_dead = true
var speed = 0
var type = null
var movedir = Vector2()
var spritedir = -1  # -1 for left, 1 for right

@onready var enums = preload("../enums.gd")
@onready var sprite = $Sprite2D

enum STATE {
	IDLE
	# Add more states as needed
}

# Movement loop determines node motion
func movement_loop():
	velocity = speed * movedir
	move_and_slide()
	
	# Update spritedir based on movement direction
	if movedir.x < 0:
		spritedir = -1  # Moving left
	elif movedir.x > 0:
		spritedir = 1  # Moving right

# spritedir_loop determines the sprite's horizontal flip based on direction
func spritedir_loop():
	# Assuming the sprite is a child node of the entity
	var sprite = $Sprite  # Replace with your actual sprite node path
	
	if sprite:
		sprite.flip_h = spritedir == -1  # Flip the sprite horizontally if moving left
