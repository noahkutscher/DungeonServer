extends Spatial

onready var map = find_parent("Map")
export var enemy_type: String = "Example"

func _ready():
	map.SpawnEnemy(enemy_type, translation)
	queue_free()
