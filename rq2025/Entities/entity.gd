extends Node2D

#An entity is the primary active node type
#Npcs, Players, and Enemies are defined by the superclass entity

#Entities all have some constants

var health = 0
var is_dead = true
var speed = 0
var type = null
var spritedir = -1

func movement_loop():
	pass
	
func spritedir_loop():
	pass
