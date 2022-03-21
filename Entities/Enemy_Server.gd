extends KinematicBody

class_name Enemy

var enemy_id = 0

onready var fov_box = $Fov
var target = null
var speed = 8
var velocity: Vector3
var max_terminl_velocity: float = 54
var gravity: float = 0.98

var meele_range = 2
var in_meele_range = false

var despawn_time = 20.0
var despawn_cd = 0

var dead = false
var auto_attack_cd = 2.5
var auto_attack_wait = 0

onready var map_info = find_parent("Map")

# Implement Threat Management here as well !!!!!!

# TODO: do stuff
func despawn_enemy():
	pass

func on_fov_entered(body):
	if dead:
		return
	
	if body.get_class() == "PlayerTemplate":
		if target == null:
			target = body
		
func _physics_process(delta):
	if dead:
		despawn_cd += delta
		if despawn_cd >= despawn_time:
			despawn()
	else:
		handle_movement(delta)
		if target != null:
			handle_auto_attack(delta)
	
func despawn():
	print("Despawned enemy")
	map_info.enemy_list.erase(enemy_id)
	find_parent("Server").notify_enemy_despawned(enemy_id)
	queue_free()
	
func die():
	print("Enemy Died")
	target = null
	dead = true
	map_info.enemy_list[enemy_id]["EnemyState"] = "Dead"
	

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
		if direction.length() < meele_range:
			in_meele_range = true
			return
		else:
			in_meele_range = false
			
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
		
func handle_auto_attack(delta):
	auto_attack_wait += delta
	if !in_meele_range:
		return
		
	if auto_attack_wait >= auto_attack_cd:
		target.handle_dmg(self, 10)
		auto_attack_wait = 0

func handle_dmg(source, damage):
	if dead:
		return
	
	if target == null:
		if map_info.has_node("Entities/" + str(source)):
			target = map_info.get_node("Entities/" + str(source))
			
	var new_health = map_info.enemy_list[enemy_id]["EnemyHealth"] - damage
	
	map_info.enemy_list[enemy_id]["EnemyHealth"] = clamp(new_health, 0, map_info.enemy_list[enemy_id]["EnemyMaxHealth"])
	if new_health <= 0:
		die()
		
func force_target(player_id):
	target = map_info.get_node("Entities/" + str(player_id))
