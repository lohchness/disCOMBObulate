extends CharacterBody2D

@onready var sprite: Sprite2D = $CollisionShape2D/Sprite2D



func take_damage(amt) -> void:
	print("Ow!")
