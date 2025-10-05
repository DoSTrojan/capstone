extends CharacterBody2D

@export var speed: float = 80.0
@export var health: int = 3

var base_ref: Node2D
@onready var agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	# Find the base in the scene
	base_ref = get_tree().get_first_node_in_group("base")
	if base_ref:
		agent.target_position = base_ref.global_position

func _physics_process(delta: float):
	if base_ref == null:
		return

	# Continuously update target in case base moves (yours doesn’t, but this is safe)
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
		queue_free()

func attack_base():
	# Placeholder – you can add logic to damage base’s health
	print("Enemy reached the base!")
	queue_free()
