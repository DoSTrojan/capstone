extends CharacterBody2D

@export var speed: float = 80.0
@export var health: int = 1

signal died(value: int)  # Signal to emit when enemy dies, value = enemy's max health

var max_health: int
var base_ref: Node2D
@onready var agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	# Store the initial health as max health
	max_health = health
	
	$AnimatedSprite2D.play()
	
	# Find the base in the scene
	base_ref = get_tree().get_first_node_in_group("base")
	if base_ref:
		agent.target_position = base_ref.global_position

func _physics_process(delta: float):
	if base_ref == null:
		return

	# Continuously update target in case base moves
	agent.target_position = base_ref.global_position

	# Get next navigation point
	var next_point = agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	# Check if reached the base
	if global_position.distance_to(base_ref.global_position) < 16.0:
		attack_base()

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		# Emit the max_health as score
		emit_signal("died", max_health)
		queue_free()

func attack_base():
	print("Enemy reached the base!")
	queue_free()
