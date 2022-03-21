extends Node

var GUID_counter = 1

func GUID():
	var guid = GUID_counter
	print("Requested GUID ", guid)
	GUID_counter += 1
	return guid
