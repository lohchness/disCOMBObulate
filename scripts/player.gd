class_name Player
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


func _ready() -> void:
	pass


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

func _on_dash_state_physics_processing(delta: float) -> void:
	velocity = direction * roll_speed(dash_timer.wait_time-dash_timer.time_left) * DASH_SPEED
	
	move_and_slide()

func roll_speed(t: float):
	return dashcurve.sample(t)


## Attacking

var attack_number = 0

@onready var primary_expire: Timer = $PrimaryExpire
@onready var primary_cooldown: Timer = $PrimaryCooldown

@onready var ap_sword: AnimationPlayer = $SwordAnimation
@onready var sword_anchor = $SwordAnchor
@onready var sword_sprite: Sprite2D = $SwordAnchor/Sword

func _on_sword_idle_state_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("primary"):
		# Primary cooldown timer off cooldown
		if primary_cooldown.is_stopped() and attack_number == 0:
			statechart.send_event("attack1")
		
		# Primary combo expire timer has not expired yet
		if not primary_expire.is_stopped():
			if attack_number == 1:
				statechart.send_event("attack2")
				
			elif attack_number == 2:
				statechart.send_event("attack3")


func _on_attack_1_state_entered() -> void:
	primary_expire.start() # Start combo expire timer
	
	attack_number = 1
	ap_sword.play("Attack1")
	print("Attack 1 entered")

func _on_attack_2_state_entered() -> void:
	primary_expire.start()
	
	attack_number = 2
	ap_sword.play("Attack2")
	print("Attack 2 entered")

func _on_attack_3_state_entered() -> void:
	# Immediately start cooldown
	primary_expire.stop()
	primary_cooldown.start()
	
	ap_sword.play("Attack3")
	print("Attack 3 entered")


func _on_sword_animation_animation_finished(anim_name: StringName) -> void:
	statechart.send_event("animation_finished")
	ap_sword.play("SwordIdle")

# Timer for primary combo
func _on_primary_expire_timeout() -> void:
	primary_cooldown.start()
	print("Primary combo expired! Starting cooldown...")
	

# Timer for primary attack cooldown.
func _on_primary_cooldown_timeout() -> void:
	attack_number = 0
	print("Primary attack ready!")


func _on_sword_idle_state_physics_processing(delta: float) -> void:
	var mousepos: Vector2 = get_global_mouse_position()
	
	#$SwordAnchor.rotation = get_angle_to(get_global_mouse_position())
	sword_anchor.rotation = lerp_angle(sword_anchor.rotation, get_angle_to(mousepos), 20 * delta)
	
	var d = mousepos - position
	sword_sprite.scale.y = (-1 if d.x < 0 else 1)



## DAMAGING ENEMIES


func _on_sword_hitbox_area_entered(area: Area2D) -> void:
	print("Here")
	if area.owner.has_method("take_damage"):
		area.owner.take_damage(10)
	

## LEVELING

var current_level = 1
var current_exp = 0
@onready var expbar = $UI/ExpBar/ExperienceBar

func _on_player_pickup_radius_area_entered(area: Area2D) -> void:
	if area.is_in_group("Orb"):
		current_exp += 3
		
		if current_exp >= points_this_level(current_level):
			level_up()
		
		expbar.curr_exp_percentage = current_exp / points_this_level(current_level)
		

func points_this_level(level):
	var exp = 1.5
	var base_exp = 10
	return floor(base_exp * pow(level, exp))

func level_up():
	current_exp -= points_this_level(current_level)
	current_level += 1
	
	#print()
