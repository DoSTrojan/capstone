extends Node2D

@export var range := 300.0       # tower detection range
@export var fire_rate := 1.0     # seconds between shots
@export var damage := 1
@export var color_preview: Color = Color(1, 0, 0, 0.4)
@export var damage_anim_scale := 1.5
@export var damage_anim_time := 0.2

@onready var radius_display: Line2D = $RadiusDisplay if has_node("RadiusDisplay") else null
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

var target: Node = null
var active: bool = false
var is_preview: bool = false
var original_scale := Vector2.ONE

func _ready():
	add_to_group("structures")

	if sprite:
		original_scale = sprite.scale

	# Setup timer
	if has_node("Timer"):
		$Timer.wait_time = fire_rate
		$Timer.start()
		$Timer.paused = not active

	# Draw radius circle
	if radius_display:
		draw_radius_circle()
		radius_display.visible = is_preview
	else:
		push_warning("No RadiusDisplay node found in tower!")

func set_active(state: bool):
	active = state
	if has_node("Timer"):
		$Timer.paused = not state

func set_preview(state: bool):
	is_preview = state
	if radius_display:
		radius_display.visible = state

func draw_radius_circle():
	if not radius_display:
		return
	var points = []
	var segments = 64
	for i in range(segments + 1):
		var angle = i * TAU / segments
		points.append(Vector2(cos(angle), sin(angle)) * range)
	radius_display.clear_points()
	radius_display.width = 2.0
	radius_display.default_color = color_preview
	radius_display.points = points

func _process(_delta):
	# Skip targeting logic if preview or inactive
	if is_preview or not active:
		return

	# Targeting
	if not target or not is_instance_valid(target) or target.global_position.distance_to(global_position) > range:
		target = get_nearest_enemy()

func get_nearest_enemy() -> Node:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest: Node = null
	var closest_dist = range
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var dist = global_position.distance_to(e.global_position)
		if dist < closest_dist:
			closest = e
			closest_dist = dist
	return closest

func _on_timer_timeout():
	if is_preview or not active:
		return
	if target and is_instance_valid(target):
		shoot(target)

func shoot(enemy):
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)

	# Play damage animation
	play_damage_animation()

# Animate scale as damage feedback
func play_damage_animation():
	if not sprite:
		return

	var tween = create_tween()
	tween.tween_property(sprite, "scale", original_scale * damage_anim_scale, damage_anim_time / 2)
	tween.tween_property(sprite, "scale", original_scale, damage_anim_time / 2).set_delay(damage_anim_time / 2)
