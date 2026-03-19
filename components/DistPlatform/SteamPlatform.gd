extends "DistPlatform.gd"

var is_online: bool
var steam_id: int
var is_owned: bool


func setup() -> bool:
	var INIT: Dictionary = Steam.steamInit(false)

	if INIT["status"] != 1:
		print("Failed to initialize Steam: %s" % str(INIT["verbal"]))
		return false

	is_online = Steam.loggedOn()
	steam_id = Steam.getSteamID()
	is_owned = Steam.isSubscribed()

	if not is_owned:
		print("User does not own this game")
		return false

	print("Steam setup success")
	return true


func _process(delta):
	Steam.run_callbacks()


func unlock_achievement(id: String):
	Steam.setAchievement(id)
	Steam.storeStats()
