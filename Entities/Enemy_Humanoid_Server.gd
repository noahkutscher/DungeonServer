extends KinematicBody

var enemy_id = 0

onready var fov_box = $Fov
var target = null
var speed = 8
var velocity: Vector3
var max_terminl_velocity: float = 54
var gravity: float = 0.98

var meele_range = 2

onready var map_info = find_parent("Map")

# Implement Threat Management here as well !!!!!!

func on_fov_entered(body):
	if body.get_class() == "PlayerTemplate":
		if target == null:
			target = body
		
func _physics_process(delta):
	handle_movement(delta)

func _ready():
	fov_box.connect("body_entered", self, "on_fov_entered")
	map_info.enemy_list[enemy_id] = {
		"EnemyLocation": translation,
		"EnemyHealth": 100,
		"EnemyMaxHealth": 100,
		"EnemyState": "Idle",
		"time_out": 1
	}
func handle_movement(delta):
	if target != null:
		
		var direction: Vector3 = target.translation - translation
		if direction.length() < 2:
			return
			
		direction.y = 0
		
		direction = direction.normalized()
		var accel = 15
		velocity = velocity.linear_interpolate(direction * speed, accel * delta)
		
		if is_on_floor():
			velocity.y = -0.01
		else:
			velocity.y = clamp(velocity.y - gravity, -max_terminl_velocity, max_terminl_velocity)
		
		velocity = move_and_slide(velocity, Vector3.UP)
		map_info.enemy_list[enemy_id]["EnemyLocation"] = translation

func handle_dmg(source, damage):
	if target == null:
		if map_info.has_node("Players/" + str(source)):
			target = map_info.get_node("Players/" + str(source))
			
	var new_health = map_info.enemy_list[enemy_id]["EnemyHealth"] - damage
	map_info.enemy_list[enemy_id]["EnemyHealth"] = clamp(new_health, 0, map_info.enemy_list[enemy_id]["EnemyMaxHealth"])
