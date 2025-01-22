extends Node2D


var num_slots = 3

@onready var wind1: Texture = preload("res://assets/sprites/powerup/Wind1.png")
@onready var wind2: Texture = preload("res://assets/sprites/powerup/Wind2.png")
@onready var wind3: Texture = preload("res://assets/sprites/powerup/Wind3.png")




func current_powerups(powerups: Array[BasePowerup]):
	for powerup in powerups:
		
