extends Node2D

# === Enemy scenes ===
@export var enemy_1_scene: PackedScene = preload("res://Scenes/enemies/enemy_1.tscn")
@export var enemy_2_scene: PackedScene = preload("res://Scenes/enemies/enemy_2.tscn")

# === Sprite sheet for spawner levels ===
@export var level_1_region: Rect2 = Rect2(160, 112, 16, 16)
@export var level_2_region: Rect2 = Rect2(208, 112, 16, 16)
@export var level_3_region: Rect2 = Rect2(256, 112, 16, 16)

# === Controls ===
@export var spawn_interval: float = 2.0
@export var growth_rate: float = 1.0
@export var spread_threshold: float = 10.0
@export var spread_distance: float = 16.0
@export var grid_size: float = 32.0
@export var enemy_2_threshold: float = 11.0

@export var map_min: Vector2 = Vector2(16, 16)
@export var map_max: Vector2 = Vector2(1584, 884)

# === Internal state ===
var value: float = 0.0
var timer: Timer
var current_level: int = 0

func _ready():
	# Enemy spawning timer
	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_spawn_timeout)

	# Make sure Sprite2D is visible and uses region
	$Sprite2D.visible = true
	$Sprite2D.region_enabled = true
	$Sprite2D.scale = Vector2(2, 2)  # optional for testing visibility

	update_sprite()

func _process(delta: float):
	value += growth_rate * delta
	update_sprite()
	if value >= spread_threshold:
		spread()

func _on_spawn_timeout():
	var enemy_scene: PackedScene
	if value >= enemy_2_threshold:
		enemy_scene = enemy_2_scene
	else:
		enemy_scene = enemy_1_scene

	var enemy = enemy_scene.instantiate()
	enemy.position = global_position
	get_parent().add_child(enemy)

func spread():
	var directions = [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]
	var new_spawner_scene = preload("res://Scenes/buildings/spawner.tscn")
	var spawner_size = Vector2(16, 16) * $Sprite2D.scale

	while directions.size() > 0:
		var index = randi() % directions.size()
		var dir = directions[index]
		directions.remove_at(index)  # remove tried direction

		var new_pos = global_position + dir * spawner_size
		new_pos = snap_to_grid(new_pos, grid_size)

		# Skip if outside map
		if new_pos.x < map_min.x or new_pos.x + spawner_size.x > map_max.x:
			continue
		if new_pos.y < map_min.y or new_pos.y + spawner_size.y > map_max.y:
			continue

		# Check overlap
		var overlap = false
		for spawner in get_parent().get_children():
			if spawner == self:
				continue
			if spawner is Node2D and spawner.position.distance_to(new_pos) < 1.0:
				overlap = true
				break

		# Spawn if valid
		if not overlap:
			var new_spawner = new_spawner_scene.instantiate()
			new_spawner.position = new_pos
			get_parent().add_child(new_spawner)
			
			# Only subtract threshold if spawn succeeded
			value -= spread_threshold
			return  # exit after spawning

	# No eligible Spawners → do not subtract value


func snap_to_grid(pos: Vector2, grid_size: float = 32.0) -> Vector2:
	return Vector2(
		round(pos.x / grid_size) * grid_size,
		round(pos.y / grid_size) * grid_size
	)

func update_sprite():
	var level = 0

	if value >= enemy_2_threshold:
		level = 2
	else:
		level = 1

	if level != current_level:
		match level:
			1: $Sprite2D.region_rect = level_1_region
			2: $Sprite2D.region_rect = level_2_region
			3: $Sprite2D.region_rect = level_3_region

		current_level = level
