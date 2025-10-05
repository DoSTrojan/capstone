extends Node2D

# Link directly to enemy_1 scene
@export var enemy_scene: PackedScene = preload("res://Scenes/enemies/enemy_1.tscn")

# Controls for spawning enemies
@export var spawn_interval: float = 2.0

# Growth & spreading system
@export var growth_rate: float = 1.0       # how fast "value" increases per second
@export var spread_threshold: float = 10.0 # value needed before creating another spawner
@export var spread_distance: float = 120.0 # how far away new spawner appears

var value: float = 0.0
var timer: Timer

func _ready():
	# enemy spawning timer
	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_spawn_timeout)

func _process(delta: float):
	value += growth_rate * delta
	if value >= spread_threshold:
		spread()
		value = 0.0  # reset after spreading (or remove this if you want it to grow continuously)

func _on_spawn_timeout():
	var enemy = enemy_scene.instantiate()
	enemy.position = global_position
	get_parent().add_child(enemy)

func spread():
	# Define the four cardinal directions
	var directions = [
		Vector2.RIGHT,
		Vector2.UP,
		Vector2.LEFT,
		Vector2.DOWN
	]
	
	var new_spawner_scene = preload("res://Scenes/buildings/spawner.tscn")

	for dir in directions:
		var new_pos = global_position + dir * spread_distance
		
		# Check for overlapping spawners
		var overlap = false
		for spawner in get_parent().get_children():
			if spawner != self and spawner.position.distance_to(new_pos) < 1.0:
				overlap = true
				break
		
		# If no spawner overlaps, spawn here
		if not overlap:
			var new_spawner = new_spawner_scene.instantiate()
			new_spawner.position = new_pos
			get_parent().add_child(new_spawner)
