extends CharacterBody2D


const MOVE_SPEED = 750
const MOVE_ACCEL = 350

@onready var ap: AnimationPlayer = $Movement
@onready var sprite: Sprite2D = $Sprite2D

@onready var statechart = $StateChart
@export var dashcurve: Curve

var direction: Vector2
var is_moving: bool

## Dashing
var is_dashing: bool = false
var dash_cooldown: float = 3         # Time to wait after dashes are spent
var can_dash = true

# Dash speed and DashTimer wait_time affects distance
@onready var dash_timer = $DashTimer
const DASH_SPEED = 3000


func _physics_process(delta: float) -> void:
	if direction.x != 0:
		sprite.flip_h = (direction.x < 0)

# Polling (single key presses)
func _on_basic_state_input(event: InputEvent) -> void:
	# Dashing supercedes all movement
	if event.is_action_pressed("dash") and can_dash:
		$StateChart.send_event("on_dash")

func _on_idle_state_physics_processing(delta: float) -> void:
	ap.play("Idle")
	move_and_slide()
	if Input.get_vector("left", "right", "up", "down"):
		statechart.send_event("on_move")
	

func _on_run_state_physics_processing(delta: float) -> void:
	ap.play("Run")
	direction = Input.get_vector("left", "right", "up", "down")
	velocity.x = move_toward(velocity.x, MOVE_SPEED * direction.x, MOVE_ACCEL)
	velocity.y = move_toward(velocity.y, MOVE_SPEED * direction.y, MOVE_ACCEL)
	move_and_slide()
	
	is_moving = velocity.length_squared() >= 0.005
	
	if not is_moving:
		$StateChart.send_event("on_idle")
	

## Dashing

func _on_dash_timer_timeout() -> void:
	can_dash = true
	statechart.send_event("finish_dash")

func _on_dash_state_entered() -> void:
	#if direction == Vector2.ZERO:
		#$StateChart.send_event("finish_dash")
	
	dash_timer.start()
	can_dash = false
	print(direction)

func _on_dash_state_physics_processing(delta: float) -> void:
	velocity = direction * roll_speed(dash_timer.wait_time-dash_timer.time_left) * DASH_SPEED
	
	move_and_slide()

func roll_speed(t: float):
	return dashcurve.sample(t)
