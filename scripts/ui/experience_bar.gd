extends Sprite2D

var max_x_scale = 15
var curr_exp_percentage:float = 0

func _physics_process(delta: float) -> void:
	scale = Vector2(curr_exp_percentage * max_x_scale, .24)
