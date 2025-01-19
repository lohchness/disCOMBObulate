extends CharacterBody2D

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: Sprite2D = $CollisionShape2D/Sprite2D

@export var target_character: CharacterBody2D

var move_speed = 300

func _ready() -> void:
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	actor_setup.call_deferred()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(target_character.position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _physics_process(delta: float) -> void:
	#if navigation_agent.is_navigation_finished():
		#return
	
	set_movement_target(target_character.position)
	
	#var direction = navigation_agent.get_next_path_position() - global_position
	var direction = global_position.direction_to(navigation_agent.get_next_path_position())
	velocity = direction * move_speed
	move_and_slide()
	
	if direction.x > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
