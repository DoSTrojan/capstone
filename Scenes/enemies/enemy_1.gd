extends CharacterBody2D


const SPEED = 200
@export var base: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D


func _physics_process(_delta: float) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * SPEED
	move_and_slide()

func makepath() -> void:
	nav_agent.target_position = base.global_position



func _on_timer_timeout() -> void:
	makepath()
