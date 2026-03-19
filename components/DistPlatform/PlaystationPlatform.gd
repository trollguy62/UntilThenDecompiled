extends "DistPlatform.gd"


func setup() -> bool:
	return true

func _process(delta):
	var newGame = Game.is_new_game()
	var scene = get_tree().current_scene
	var sName = scene.name
	var start = PSActivities.CheckActivityIntent(newGame, sName)

	if start and not newGame:
		Game.start()
	elif start:
		Game.to_scene_key(Game.FIRST_SCENE_KEY)

func unlock_achievement(id: String):
	var tID = getTrophyID(id)
	PSActivities.UnlockTrophy(tID)

	if id == "ACH_BUTTERFLY":
		PSActivities.EndActivity()

func getTrophyID(name: String) -> int:
	match name:
		"ACH_COCOON":
			return 1
		"ACH_LARVA":
			return 2
		"ACH_BUTTERFLY":
			return 3
		"ACH_TVM_P1_COINS_ONLY":
			return 4
		"ACH_TVM_WRONG_STATION_10":
			return 5
		"ACH_MATIGAS_ULO":
			return 6
		"ACH_HEAD_ARMOR":
			return 7
		"ACH_SOCMED_LIKE_OWN_COMM_1":
			return 8
		"ACH_SOCMED_SHARE_POST_10":
			return 9
		"ACH_SOCMED_LIKE_COMM_100":
			return 10
		"ACH_LIE_TO_LOUISE":
			return 11
		"ACH_MEME_REPORT":
			return 12
		"ACH_FISHBALL_PERFECT":
			return 13
		"ACH_RUN_ALL_FAIL":
			return 14
		"ACH_RUN_ALL_OK":
			return 15
		"ACH_DART_INSTANT_BULLSEYE":
			return 16
		"ACH_ASWANG_WIN":
			return 17
		"ACH_DASURV":
			return 18
		"ACH_COOKIES_HEART":
			return 19
		"ACH_COOKIES_EMOJI":
			return 20
		"ACH_VIDEOKE_85_99":
			return 21
		"ACH_VIDEOKE_100":
			return 22
		"ACH_MANIA_AUDITION_100":
			return 23
		"ACH_BIKE_WIN":
			return 24
		"ACH_JEEP_0":
			return 25
		"ACH_JEEP_100":
			return 26
		"ACH_CUP_MORAL":
			return 27
		"ACH_CARVE_CRAZY":
			return 28
		"ACH_MISSING_PIECE":
			return 29
		_:
			return -1

func StartActivity():
	PSActivities.StartActivity()

func ResumeActivity():
	PSActivities.ResumeActivity()
