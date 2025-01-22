class_name BasePowerup
extends Resource

@export var icon: Texture2D
@export var powerup_name: String
@export var powerup_description: String

var permanent_upgrade_applied = false



func player_permanent_buff():
	pass


func on_hit(wriggler: Wriggler):
	pass
