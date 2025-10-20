extends Node2D

@export var spawner_scene: PackedScene = preload("res://Scenes/buildings/spawner.tscn")
@export var map_min: Vector2 = Vector2(0, 0)
@export var map_max: Vector2 = Vector2(1600, 900)
@export var tile_size: Vector2 = Vector2(32, 32)  # size of one tile
@export var base_scene: PackedScene

var spawn_timer: Timer

func _ready():
	# Spawn base in center of map
	spawn_base_center()
	
	# Spawn the first spawner immediately
	spawn_spawner_on_edge()

	# Setup repeating timer for every 10 seconds
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 10.0
	spawn_timer.autostart = true
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	spawn_timer.timeout.connect(spawn_spawner_on_edge)
	
func spawn_base_center():
	var base_instance = base_scene.instantiate()
	
	# Center of the game world
	var map_size = Vector2(1600, 900)  # map size in pixels
	base_instance.position = map_size / 2
	
	add_child(base_instance)
	
	# Add to group
	base_instance.add_to_group("base")

func spawn_spawner_on_edge():
	# Choose a random edge: 0=top, 1=bottom, 2=left, 3=right
	var edge = randi() % 4
	var x = 0.0
	var y = 0.0

	match edge:
		0:  # top edge, y = map_min.y + 1 tile
			x = randf_range(map_min.x + tile_size.x, map_max.x - 2 * tile_size.x)
			y = map_min.y + tile_size.y
		1:  # bottom edge, y = map_max.y - 2 tiles
			x = randf_range(map_min.x + tile_size.x, map_max.x - 2 * tile_size.x)
			y = map_max.y - 2 * tile_size.y
		2:  # left edge, x = map_min.x + 1 tile
			x = map_min.x + tile_size.x
			y = randf_range(map_min.y + tile_size.y, map_max.y - 2 * tile_size.y)
		3:  # right edge, x = map_max.x - 2 tiles
			x = map_max.x - 2 * tile_size.x
			y = randf_range(map_min.y + tile_size.y, map_max.y - 2 * tile_size.y)

	var spawner_pos = Vector2(x, y)

	# Snap to grid
	spawner_pos = Vector2(round(spawner_pos.x / tile_size.x) * tile_size.x,
						  round(spawner_pos.y / tile_size.y) * tile_size.y)

	# Instantiate spawner
	var spawner = spawner_scene.instantiate()
	spawner.position = spawner_pos
	add_child(spawner)
