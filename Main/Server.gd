extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

var player_state_collection = {}

onready var combat_func = get_node("Combat")
onready var player_set = get_node("Map/Players")
onready var map_functions = get_node("Map")

func _ready():
	StartServer()
	
func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(player_id):
	print("User ", str(player_id), " connected")
	map_functions.SpawnPlayer(player_id, Vector3(0, 0, 0))
	rpc_id(0, "SpawnNewPlayer", player_id, Vector3(0, 0, 0))
	
func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " disconnected")
	player_state_collection.erase(player_id)
	map_functions.DespawnPlayer(player_id)
	rpc_id(0, "DespawnNewPlayer", player_id)
	
remote func RecievePlayerState(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
			player_set.get_node(str(player_id)).MovePlayer(player_state["P"])
	else:
		player_state_collection[player_id] = player_state
		
	
		
func SendWorldState(world_state):
	rpc_unreliable_id(0, "RecieveWorldState", world_state)
	
remote func FetchServerTime(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)
	
remote func DetermineLatency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnLatency", client_time)

remote func start_cast(target, spell_id):
	combat_func.start_cast(target, spell_id)
	
func notify_cast_finished(player_id):
	rpc_id(player_id, "notify_cast_finished")
