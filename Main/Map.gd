extends Node

var enemy_id_counter = 1
var enemy_maximum = 3
var open_locations = [0, 1, 2, 3, 4]

var enemy_list = {}
var player_info = {}

onready var Server = find_parent("Server")

var enemy_prefab = preload("res://Entities/Enemy_Humanoid_Server.tscn")
var player_prefab = preload("res://Entities/PlayerTemplate_Server.tscn")
var map_prefab = preload("res://Maps/Map_A/Map_A.tscn")

func _ready():
	var map = map_prefab.instance()
	map.name = "active_map"
	add_child(map)
	
func SpawnEnemy(type, location):
	var enemy = enemy_prefab.instance()
	var guid = Util.GUID()
	enemy.name = str(guid)
	enemy.translation = location
	enemy.enemy_id = guid
	get_node("Entities").add_child(enemy)
	
func SpawnPlayer(player_id, location):
	var player = player_prefab.instance()
	player.name = str(player_id)
	player.player_id = player_id
	player.translation = location
	get_node("Entities").add_child(player)
	
func DespawnPlayer(player_id):
	player_info.erase(player_id)
	get_node("Entities/" + str(player_id)).queue_free()
