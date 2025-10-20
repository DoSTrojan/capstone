extends CanvasLayer

# Export the structure scenes
@export var tower_scene: PackedScene
@export var mine_scene: PackedScene

# Internal state
var selected_structure: PackedScene = null
var preview_instance: Node2D = null
var score: int = 0  # Track total score

# UI element for score
@onready var score_label: Label = $Panel/ScoreLabel

func _ready():
	add_to_group("UI")
	
	# Connect buttons
	$Panel/HBoxContainer/Tower.pressed.connect(func():
		select_structure(tower_scene)
	)
	$Panel/HBoxContainer/Mine.pressed.connect(func():
		select_structure(mine_scene)
	)
	
	# Initialize score display
	_update_score_label()

	# Connect all existing enemies
	_connect_enemies()

	# Monitor the scene tree for new enemies
	get_tree().connect("node_added", Callable(self, "_on_node_added"))

func _connect_enemies():
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.has_signal("died") and not enemy.is_connected("died", Callable(self, "_on_enemy_died")):
			enemy.connect("died", Callable(self, "_on_enemy_died"))

func _on_node_added(node: Node):
	# If a new enemy node is added, connect to its signal
	if node.is_in_group("enemy") and node.has_signal("died"):
		node.connect("died", Callable(self, "_on_enemy_died"))

func select_structure(structure: PackedScene):
	selected_structure = structure
	print("Selected structure: ", structure)

	# Remove old preview if it exists
	if preview_instance:
		preview_instance.queue_free()

	# Create new preview instance
	preview_instance = selected_structure.instantiate()
	preview_instance.modulate = Color(1, 1, 1, 0.5)  # semi-transparent
	get_tree().current_scene.add_child(preview_instance)

	# Set preview mode
	if preview_instance.has_method("set_preview"):
		preview_instance.set_preview(true)
	if preview_instance.has_method("set_active"):
		preview_instance.set_active(false)

func _process(_delta):
	if preview_instance:
		preview_instance.global_position = get_viewport().get_mouse_position()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if selected_structure and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			place_structure(get_viewport().get_mouse_position())
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_selection()

func place_structure(position: Vector2):
	if not selected_structure:
		return

	var instance = selected_structure.instantiate()
	instance.position = position

	if instance.has_method("show_radius"):
		instance.show_radius(false)
	if instance.has_method("set_active"):
		instance.set_active(true)
	if instance.has_method("set_preview"):
		instance.set_preview(false)

	get_tree().current_scene.add_child(instance)

	if preview_instance:
		preview_instance.queue_free()
		preview_instance = null
	selected_structure = null

func cancel_selection():
	if preview_instance:
		preview_instance.queue_free()
		preview_instance = null
	selected_structure = null

# Called when an enemy dies
func _on_enemy_died(value: int):
	score += value
	_update_score_label()
	print("Score updated: ", score)

func _update_score_label():
	if score_label:
		score_label.text = "Score: " + str(score)
	else:
		push_warning("ScoreLabel is null, cannot update!")
