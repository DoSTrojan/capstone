extends Area2D

@export var explosion_radius := 200.0
@export var damage := 100
@export var explosion_duration := 0.3  # seconds

@onready var radius_display: Line2D = $RadiusDisplay if has_node("RadiusDisplay") else null
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

var active: bool = false       # Mine is inactive until placed
var preview: bool = false      # True if this is just a preview instance

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	if radius_display:
		radius_display.visible = false  # hidden by default

func set_active(state: bool):
	active = state

func set_preview(is_preview_state: bool):
	preview = is_preview_state
	if radius_display:
		if radius_display.points.size() == 0:  # initialize points if not drawn yet
			_draw_radius()
		radius_display.visible = is_preview_state
	modulate = Color(1, 1, 1, 0.5) if is_preview_state else Color(1, 1, 1, 1.0)

func _on_body_entered(body):
	if not active or preview:
		return  # Ignore collisions until placed or if preview

	if body.is_in_group("enemy"):
		explode()

func explode():
	# Damage enemies
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		var dist = enemy.global_position.distance_to(global_position)
		if dist < explosion_radius and enemy.has_method("take_damage"):
			enemy.take_damage(damage)

	# Play explosion animation before freeing
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", sprite.scale * 10.0, explosion_duration)
		tween.tween_property(sprite, "modulate:a", 0.0, explosion_duration)
		tween.tween_callback(Callable(self, "queue_free"))
	else:
		queue_free()

func _draw_radius():
	if not radius_display:
		return
	var points = []
	var segments = 64
	for i in range(segments + 1):
		var angle = i * TAU / segments
		points.append(Vector2(cos(angle), sin(angle)) * explosion_radius)
	radius_display.width = 2.0
	radius_display.default_color = Color(1, 0, 0, 0.4)  # red translucent
	radius_display.points = points

func show_radius(state: bool):
	if radius_display:
		radius_display.visible = state
