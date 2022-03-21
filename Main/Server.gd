extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

var player_state_collection = {}

var con_id_to_guid = {}
var guid_to_con_id = {}

onready var combat_func = get_node("Combat")
onready var player_set = get_node("Map/Entities")
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
	
	var player_guid = Util.GUID()
	con_id_to_guid[player_id] = player_guid
	guid_to_con_id[player_guid] = player_id
	print("Got ID ", str(player_guid))
	
	map_functions.SpawnPlayer(player_guid, Vector3(0, 0, 0))
	
	rpc_id(player_id, "SuccessfullyConnected", player_guid)
	rpc_id(0, "SpawnNewPlayer", player_id, Vector3(0, 0, 0), player_guid)
	
func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " disconnected")
	
	
	player_state_collection.erase(con_id_to_guid[player_id])
	map_functions.DespawnPlayer(con_id_to_guid[player_id])
	rpc_id(0, "DespawnNewPlayer", con_id_to_guid[player_id])
	
remote func RecievePlayerState(player_state):
	var con_id = get_tree().get_rpc_sender_id()
	var player_id = con_id_to_guid[con_id]
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
			player_set.get_node(str(player_id)).MovePlayer(player_state["P"])
	else:
		player_state_collection[player_id] = player_state
		
func SendWorldState(world_state):
	rpc_unreliable_id(0, "RecieveWorldState", world_state)
	
remote func FetchServerTime(client_time):
	var con_id = get_tree().get_rpc_sender_id()
	rpc_id(con_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)
	
remote func DetermineLatency(client_time):
	var con_id = get_tree().get_rpc_sender_id()
	rpc_id(con_id, "ReturnLatency", client_time)

remote func start_cast(target, spell_id):
	var con_id = get_tree().get_rpc_sender_id()
	var success = combat_func.start_cast(con_id_to_guid[con_id], target, spell_id)
	rpc_id(con_id, "notify_cast_successfull", success, false)
	
func notify_cast_finished(player_guid):
	rpc_id(guid_to_con_id[player_guid], "notify_cast_finished")
	
func notify_enemy_despawned(enemy_id):
	rpc_id(0, "despawn_enemy",enemy_id)
