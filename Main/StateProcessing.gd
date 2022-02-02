extends Node

var world_state = {}
var state_tick = 0

func _physics_process(delta):
	if state_tick < 3:
		state_tick += 1
		return
	
	state_tick = 0
	if not get_parent().player_state_collection.empty():
		var player_state = get_parent().player_state_collection.duplicate(true)
		for player in player_state.keys():
			player_state[player].erase("T")
		world_state["T"] = OS.get_system_time_msecs()
		world_state["Players"] = player_state
		world_state["Enemies"] = get_node("../Map").enemy_list.duplicate(true)
		# Verification
		# Anti-Cheat
		# Cuts (chunks / maps)
		# Physics checks
		# etc
		get_parent().SendWorldState(world_state)
