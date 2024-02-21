extends CharacterBody3D

const MAX_STAMINA: float = 3.99
const STAMINA_RATE: float = 3.0
const MAX_SPEED: float = 400.0

@export var fcurve: Curve

@export var player_modulate: Color = Color.WHITE

@export var move_speed: float = 200.0

@export var jump_height: float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float

@export var friction: float = 50.0

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@onready var feathers: Array[Node3D] = [
	$Feather/F1,
	$Feather/F2,
	$Feather/F3,
	$Feather/F4,
	$Feather/F5
]

@onready var particles: GPUParticles3D = $Feather/GPUParticles2D as GPUParticles3D
@onready var ftimer: Timer = $Timer as Timer

@onready var visual: CreatureVisual = $CreatureVisual as CreatureVisual

#@onready var eaten_area: Area2D = $Eaten as Area3D
#
#@onready var jump_sound: AudioStreamPlayer2D = $Jump as AudioStreamPlayer3D
#
#@onready var feather_sound: AudioStreamPlayer2D = $Feather/FNoise as AudioStreamPlayer3D

@export var feather: Area3D
@export var feather_impact: Vector3 = Vector3(10000, 500, 0)

var eaten: bool = false

var n_vel: Vector3 = Vector3()
var f_vel: Vector3 = Vector3()

var stamina: float = MAX_STAMINA
var falling: bool = false

var keyboard_input: bool = true

signal player_died
signal player_eaten

func _ready() -> void:
	#$CreatureVisual.modulate = player_modulate
	pass

func _physics_process(delta: float) -> void:
	if not eaten and Input.is_action_just_released("jump") and not falling:
		falling = true
	velocity.y += get_gravity() * delta
	if not eaten:
		velocity.x = get_input_velocity() * move_speed
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			falling = false
			jump()
			#jump_sound.play()
		
		feather_func_one()
		velocity += f_vel
		velocity.x = clampf(velocity.x, -MAX_SPEED, MAX_SPEED)
		move_and_slide()
		velocity.x -= f_vel.x
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0.0, friction)
			var ostam: float = stamina
			stamina = MAX_STAMINA
			if floor(ostam) < floor(stamina):
				pass # stamina fill v effect
	else:
		move_and_slide()
	
	#visual.set_velocity(velocity, is_on_floor())
	
	#if not eaten and velocity.y > 0:
		#var eatens: Array = eaten_area.get_overlapping_areas()
		#if eatens.size() > 0:
			#Sounds.ate()
			#eaten = true
			#player_eaten.emit()
			#var body: CreatureVisual = eatens.front().get_parent().get_parent().get_parent()
			#if is_instance_valid(body) and body.has_method("mouth_mask"):
				#body.mouth_mask()
				#get_tree().call_group("GameCam", "super_zoom")
				#Fader.level_complete()
				#get_tree().create_timer(0.3).timeout.connect(queue_free)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		keyboard_input = true
	if event is InputEventJoypadButton:
		keyboard_input = false


func feather_func_one() -> void:
	f_vel = Vector3.ZERO
	var r1: Vector3 = feather.position
	if keyboard_input:
		var mpos = get_viewport().get_mouse_position()
		feather.look_at(Vector3(mpos.x, mpos.y, 0))
	else:
		#feather.look_at(feather.global_position + Input.get_vector("feather_left", "feather_right", "feather_up", "feather_down"))
		pass
	var r2: Vector3 = feather.position
	var vel: float = minf(abs(r1.angle_to(r2)), 0.025)
	
	#feather_sound.volume_db = fcurve.sample_baked(remap(vel, 0.0, 0.025, 0.0, 1.0)) * -80.0
	var pos: Vector3 = lerp(r1, r2, 0.5)
	if stamina > 0.0:
		f_vel -= vel * pos
		if not is_on_floor():
			f_vel.x *= feather_impact.x
		f_vel.y *= feather_impact.y
		stamina -= vel * STAMINA_RATE
	# do feather effect
	
	if vel > 0.02:
		if stamina > 0 and ftimer.is_stopped():
			ftimer.start()
	else:
		ftimer.stop()
	
	for feather in feathers:
		feather.show()
	if stamina < 3:
		feathers[1].hide()
	if stamina < 2:
		feathers[2].hide()
	if stamina < 1:
		feathers[3].hide()
	if stamina < 0:
		feathers[4].hide()
	
	if stamina > 0:
		for body in feather.get_overlapping_areas():
			var ppp: Node = body.get_parent().get_parent().get_parent().get_parent()
			if ppp and ppp.has_method("tickle_increase"):
				ppp.tickle_increase(vel)


func get_gravity() -> float:
	if not falling:
		falling = velocity.y > 0.0
	if falling:
		return fall_gravity
	return jump_gravity


func jump() -> void:
	velocity.y = jump_velocity
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	visual.scale.x = 0.075
	tween.tween_property(visual, "scale:x", 0.085, 1.0)


func get_input_velocity() -> float:
	var horizontal := 0.0
	
	if Input.is_action_pressed("left"):
		horizontal -= 1.0
	if Input.is_action_pressed("right"):
		horizontal += 1.0
	
	return horizontal


func _on_timer_timeout() -> void:
	particles.emitting = true
	await get_tree().create_timer(0.02).timeout
	particles.emitting = false


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if global_position.y < 50:
		return
	player_died.emit()
	get_tree().call_group("GameHolder", "restart_level")
	queue_free()
