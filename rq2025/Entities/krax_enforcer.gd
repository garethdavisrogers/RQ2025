extends "res://Entities/entity.gd"

var role = null

func _ready():
	add_to_group("ENEMY")

func _physics_process(_delta):
	movement_loop()
	spritedir_loop()
