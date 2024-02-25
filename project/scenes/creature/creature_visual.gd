class_name CreatureVisual
extends Node2D

@onready var visual: Node2D = $Node2D as Node2D
@onready var move_legs: AnimatedSprite2D = $Node2D/Feet as AnimatedSprite2D
@onready var air_legs: AnimatedSprite2D = $Node2D/Body/Feet2 as AnimatedSprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer as AnimationPlayer

signal mouth_opened
signal mouth_closed

func set_velocity(velocity: Vector2, grounded: bool) -> void:
	if abs(velocity.x) > 1:
		if velocity.x < -10:
			visual.scale.x = -1
		if velocity.x > 10:
			visual.scale.x = 1
	
	if grounded:
		if abs(velocity.x) < 1:
			animation.stop()
			move_legs.hide()
			air_legs.frame = 0
			air_legs.show()
		else:
			if not animation.is_playing():
				animation.play("bob")
			if velocity.x < -1:
				move_legs.show()
				air_legs.hide()
			if velocity.x > 1:
				move_legs.show()
				air_legs.hide()
	else:
		animation.stop()
		move_legs.hide()
		air_legs.show()
		if velocity.y < 0:
			air_legs.frame = 1
		else:
			air_legs.frame = 2


func laugh() -> void:
	animation.play("laugh")


func mouth_mask() -> void:
	$Node2D/Body/Node2D/MouthMask.show()
