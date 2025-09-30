class_name Player extends CharacterBody2D

# ============================================
# 2D PLATFORMER MOVEMENT SCRIPT
# Features: Double Jump, Dash, Wall Climb,
# Coyote Time, Variable Jump Height, etc.
# ============================================

#region Movement
# Movement Parameters
@export_group("Movement")
@export var move_speed: float = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 1800.0
@export var air_acceleration: float = 1200.0
@export var air_friction: float = 400.0

# Jump Parameters
@export_group("Jump")
@export var jump_velocity: float = -500.0
@export var jump_cut_multiplier: float = 0.5  # For variable jump height
@export var max_fall_speed: float = 800.0
@export var fast_fall_multiplier: float = 1.5  # When holding down

# Double Jump
@export_group("Double Jump")
@export var enable_double_jump: bool = true
@export var double_jump_velocity: float = -450.0
@export var double_jump_count: int = 1

# Coyote Time (grace period after leaving ground)
@export_group("Coyote Time")
@export var coyote_time: float = 0.15

# Jump Buffer (press jump slightly before landing)
@export_group("Jump Buffer")
@export var jump_buffer_time: float = 0.1

# Dash
@export_group("Dash")
@export var enable_dash: bool = true
@export var dash_speed: float = 700.0
@export var dash_duration: float = 0.2

# Wall Mechanics
@export_group("Wall")
@export var enable_wall_mechanics: bool = true
@export var wall_slide_speed: float = 100.0
@export var wall_jump_velocity: Vector2 = Vector2(400, -500)
@export var wall_jump_push_time: float = 0.15  # Time before player can move after wall jump

# Gravity
@export_group("Gravity")
@export var gravity_scale: float = 1.0
@export var wall_gravity_scale: float = 0.3

@onready var animated_sprite = $Sprite2D

# Animation state tracking
var is_double_jumping: bool = false

# Internal State Variables
var jumps_remaining: int = 0
var is_dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO
var wall_jump_push_timer: float = 0.0

# Timers
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var dash_timer: float = 0.0

# Wall Detection
var is_on_wall_left: bool = false
var is_on_wall_right: bool = false
var wall_normal: Vector2 = Vector2.ZERO

# State tracking
var was_on_floor_last_frame: bool = false

# Get gravity from project settings
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	jumps_remaining = double_jump_count + 1  # +1 for initial jump

func _physics_process(delta: float) -> void:
	# Update timers
	update_timers(delta)

	# Check wall collision
	check_wall_collision()

	# Handle dash
	if is_dashing:
		handle_dash(delta)
		move_and_slide()
		return

	# Apply gravity
	apply_gravity(delta)

	# Handle wall slide
	if enable_wall_mechanics and is_on_wall_sliding():
		handle_wall_slide(delta)

	# Get input direction
	var input_direction: float = Input.get_axis("left", "right")

	# Handle wall jump
	if enable_wall_mechanics and Input.is_action_just_pressed("up") and is_on_wall_sliding():
		handle_wall_jump()
	# Handle regular jump
	elif Input.is_action_just_pressed("up"):
		jump_buffer_timer = jump_buffer_time

	# Process jump buffer
	if jump_buffer_timer > 0 and can_jump():
		handle_jump()

	# Variable jump height (release jump early for shorter jump)
	if Input.is_action_just_released("up") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier

	# Handle dash input
	if enable_dash and Input.is_action_just_pressed("dash") and can_dash:  # Using Shift key
		start_dash(input_direction)

	# Handle horizontal movement (unless in wall jump push time)
	if wall_jump_push_timer <= 0:
		handle_horizontal_movement(input_direction, delta)

	# Clamp fall speed
	velocity.y = min(velocity.y, max_fall_speed)

	# Move character
	move_and_slide()

	# Update state after movement
	update_state_after_movement()

	# Update animations
	update_animations(input_direction)

func update_timers(delta: float) -> void:
	"""Update all timers"""
	if coyote_timer > 0:
		coyote_timer -= delta

	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	if dash_timer > 0:
		dash_timer -= delta

	if wall_jump_push_timer > 0:
		wall_jump_push_timer -= delta

func check_wall_collision() -> void:
	"""Check if player is touching a wall on left or right"""
	is_on_wall_left = false
	is_on_wall_right = false

	if is_on_wall():
		wall_normal = get_wall_normal()
		is_on_wall_left = wall_normal.x > 0
		is_on_wall_right = wall_normal.x < 0

func apply_gravity(delta: float) -> void:
	"""Apply gravity with different scales for different states"""
	if not is_on_floor():
		var current_gravity = gravity * gravity_scale

		# Apply fast fall when holding down
		if Input.is_action_pressed("ui_down") and velocity.y > 0:
			current_gravity *= fast_fall_multiplier

		velocity.y += current_gravity * delta

func is_on_wall_sliding() -> bool:
	"""Check if player is wall sliding"""
	if not is_on_wall():
		return false

	if is_on_floor():
		return false

	# Must be moving into the wall or falling
	if is_on_wall_left and Input.is_action_pressed("left"):
		return true
	if is_on_wall_right and Input.is_action_pressed("right"):
		return true

	return false

func handle_wall_slide(delta: float) -> void:
	"""Handle wall sliding physics"""
	# Apply reduced gravity
	velocity.y += gravity * wall_gravity_scale * delta

	# Clamp to wall slide speed
	velocity.y = min(velocity.y, wall_slide_speed)

	# Reset jumps while on wall
	jumps_remaining = double_jump_count + 1
	can_dash = true

func handle_wall_jump() -> void:
	"""Execute a wall jump"""
	jump_buffer_timer = 0

	# Jump away from wall
	if is_on_wall_left:
		velocity = Vector2(wall_jump_velocity.x, wall_jump_velocity.y)
	else:
		velocity = Vector2(-wall_jump_velocity.x, wall_jump_velocity.y)

	# Set push timer to prevent immediate direction change
	wall_jump_push_timer = wall_jump_push_time

	# Reset jumps
	jumps_remaining = double_jump_count

func can_jump() -> bool:
	"""Check if player can jump"""
	# Can jump if on ground or within coyote time
	if is_on_floor() or coyote_timer > 0:
		return true

	# Can double jump if enabled and jumps remaining
	if enable_double_jump and jumps_remaining > 0:
		return true

	return false

func handle_jump() -> void:
	"""Execute a jump"""
	jump_buffer_timer = 0

	# Regular jump from ground or coyote time
	if is_on_floor() or coyote_timer > 0:
		velocity.y = jump_velocity
		coyote_timer = 0
		jumps_remaining = double_jump_count
		is_double_jumping = false
	# Double jump
	elif enable_double_jump and jumps_remaining > 0:
		velocity.y = double_jump_velocity
		jumps_remaining -= 1
		is_double_jumping = true

func start_dash(input_direction: float) -> void:
	"""Start a dash"""
	if not can_dash:
		return

	is_dashing = true
	can_dash = false
	dash_timer = dash_duration

	# Determine dash direction
	var dash_dir_x = input_direction
	if dash_dir_x == 0:
		dash_dir_x = 1 if not animated_sprite.flip_h else -1  # Dash in facing direction

	var dash_dir_y = 0.0
	if Input.is_action_pressed("up"):
		dash_dir_y = -1.0
	elif Input.is_action_pressed("down"):
		dash_dir_y = 1.0

	dash_direction = Vector2(dash_dir_x, dash_dir_y).normalized()
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.RIGHT

func handle_dash(_delta: float) -> void:
	"""Handle dash movement"""
	velocity = dash_direction * dash_speed

	if dash_timer <= 0:
		is_dashing = false
		velocity *= 0.5  # Reduce velocity after dash

func handle_horizontal_movement(input_direction: float, delta: float) -> void:
	"""Handle left/right movement with acceleration and friction"""
	var target_speed = input_direction * move_speed

	if is_on_floor():
		# Ground movement
		if input_direction != 0:
			velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		# Air movement
		if input_direction != 0:
			velocity.x = move_toward(velocity.x, target_speed, air_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, air_friction * delta)

	# Flip sprite based on direction
	if input_direction != 0:
		animated_sprite.flip_h = input_direction < 0

func update_state_after_movement() -> void:
	"""Update state variables after movement"""
	# Start coyote time when just leaving ground
	if was_on_floor_last_frame and not is_on_floor():
		coyote_timer = coyote_time

	# Reset jumps when landing (only when transitioning from air to ground)
	if is_on_floor() and not was_on_floor_last_frame:
		jumps_remaining = double_jump_count + 1

	# Keep jumps available while on ground
	if is_on_floor():
		jumps_remaining = double_jump_count + 1

	# Reset dash when touching floor or wall
	if is_on_floor() or is_on_wall():
		can_dash = true

	# Update state for next frame
	was_on_floor_last_frame = is_on_floor()

func update_animations(_input_direction: float) -> void:
	"""Update animation based on current movement state"""
	# Don't change animations during dash
	if is_dashing:
		return

	# Check if moving horizontally
	var is_moving = abs(velocity.x) > 10

	# Priority order: Wall Slide > Double Jump > Jump > Fall > Walk > Idle
	if not is_on_floor():
		# Check for wall slide first
		if enable_wall_mechanics and is_on_wall_sliding():
			animated_sprite.play("wall_slide")
		# Airborne animations
		elif velocity.y < 0:
			# Moving upward - jumping
			animated_sprite.play("jump")
		else:
			# Moving downward - falling
			animated_sprite.play("fall")
	else:
		# Grounded animations
		if is_moving:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")

	# Reset double jump flag when landing
	if is_on_floor():
		is_double_jumping = false

#endregion

#region Dialogue
@onready var interact_sign = $"interact label"
@onready var dialogue_label = $"Label"
@onready var animation_player = $AnimationPlayer

func show_interact_sign():
	animation_player.play("show interact sign")

func hide_interact_sign():
	animation_player.play_backwards("show interact sign")
#endregion