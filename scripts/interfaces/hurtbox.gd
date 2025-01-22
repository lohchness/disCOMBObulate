class_name Hurtbox
extends Area2D

func _init() -> void:
	# Hurtboxes will receive collisions from hitboxes
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	pass
	#connect("area_entered", self._on_area_entered)


func _on_area_entered(hitbox: Hitbox) -> void:
	pass
	#if hitbox == null:
		#return
	#
	#if owner.has_method("take_damage"):
		#owner.take_damage(hitbox.damage)
	
	
