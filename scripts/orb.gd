extends Sprite2D

var travel_to_player = false
var player: Player = null
var time_since_magnet: float = 0

func _physics_process(delta: float) -> void:
	if travel_to_player:
		global_position = global_position.lerp(player.global_position, 8 * delta * (1 + time_since_magnet))
		time_since_magnet += delta
		

func _on_magnet_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerMagnetRadius"):
		travel_to_player = true
		player = area.get_parent().get_parent()


func _on_pickup_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerPickupRadius"):
		queue_free()
