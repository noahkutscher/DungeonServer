extends Node

var active_casts = {}
onready var enemy_nodes = get_parent().get_node("Map").get_node("Enemies")


func _process(delta):
	for caster in active_casts.keys():
		active_casts[caster]["cd"] += delta
		if active_casts[caster]["cd"] >= active_casts[caster]["ttc"]:
			finish_cast(caster, active_casts[caster]["target"], active_casts[caster]["spell_id"])

func start_auto_attack(caster, target):
	# is caster in range?
	# set caster auto_attack = true
	# get player hit speed
	# start timer
	# if timer finished and still in range -> dmg calculation
	pass

func stop_auto_attack(caster):
	# set caster auto_attack = false
	pass

func start_cast(target, spell_id):
	print("Starting Cast")
	var player_id = get_tree().get_rpc_sender_id()
	var ttc = 2
	var cd = 0
	var cast_range = 20

	active_casts[player_id] = {
		"ttc": ttc,
		"cd": cd,
		"target": target,
		"spell_id": spell_id
	}

	# is caster in range?
	# set caster casting = true
	pass

func interrupt_cast(caster):
	active_casts.erase(caster)
	pass

func finish_cast(caster, target, spell_id):
	print("Finished Cast")
	active_casts.erase(caster)
	enemy_nodes.get_node(str(target)).handle_dmg(caster, 10)
	get_parent().notify_cast_finished(caster)
