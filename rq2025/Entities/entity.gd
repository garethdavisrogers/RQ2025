extends CharacterBody2D

# An entity is the primary active node type
# NPCs, Players, and Enemies are defined by the superclass entity

# Entities all have some constants
var type = null
var movedir = Vector2()
var spritedir = -1
var speed = 100

func movement_loop():
	velocity = speed * movedir
	move_and_slide()
	
func spritedir_loop():
	if movedir.x < 0:
		spritedir = -1
	elif movedir.x > 0:
		spritedir = 1
	scale.x = scale.y * spritedir
