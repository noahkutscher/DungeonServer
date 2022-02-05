extends KinematicBody

class_name PlayerTemplate

var dead = false
var player_id = 0
onready var map_info = find_parent("Map")

func get_class(): return "PlayerTemplate"

func _ready():
	map_info.player_info[player_id] = {
		"PlayerHealth": 100,
		"PlayerMaxHealth": 100
	}
	print(map_info.player_info)
	
func die():
	dead = true
	print("Player Died! >> No handler for dying implemented yet")
	pass

func MovePlayer(position):
	translation = position

func handle_dmg(source, damage):
	if dead:
		return
	var new_health = map_info.player_info[player_id]["PlayerHealth"] - damage
	map_info.player_info[player_id]["PlayerHealth"] = clamp(new_health, 0, map_info.player_info[player_id]["PlayerMaxHealth"])
	if new_health <= 0:
		die()
		
func handle_heal(source, heal):
	if dead:
		return	
	var new_health = map_info.player_info[player_id]["PlayerHealth"] + heal
	map_info.player_info[player_id]["PlayerHealth"] = clamp(new_health, 0, map_info.player_info[player_id]["PlayerMaxHealth"])
