extends Resource

const UNLOCK_ALL_KEY = "__UNLOCKALL__"
const CURRENT_VERSION = 2
const OLD_VERSION_MAGIC = "42"

@export_range (1, 3) var playthrough: int = 1:
	set(v):
		playthrough = v
		if md5 != OLD_VERSION_MAGIC:
			md5 = compute_md5()

@export var first_run := true:
	set(v):
		first_run = v
		if md5 != OLD_VERSION_MAGIC:
			md5 = compute_md5()

@export var current_scene_key := "":
	set(v):
		current_scene_key = v
		if md5 != OLD_VERSION_MAGIC:
			md5 = compute_md5()

@export var ng_plus := false
@export var ng_plus_shown_post := false
@export var ng_plus_shown_msg := false

@export var scene_progress := {}
@export var version: int = CURRENT_VERSION

@export var md5: String = Constants.OLD_SAVE_VERSION_MAGIC

var _data:
	get:
		var s = str(playthrough) + str(first_run) + str(current_scene_key) + str(scene_progress) + str(version)
		return s

@export var liked_comments := []
@export var shared_posts := []
@export var boards_cleared := []



func _init():
	if current_scene_key == "":
		current_scene_key = Game.FIRST_SCENE_KEY


func is_scene_unlocked(scene_key: String) -> bool:
	if Game.config.debug_unlock_all_scenes:
		return true

	if scene_key == Game.FIRST_SCENE_KEY:
		return true

	var state = scene_progress.get(scene_key, null)
	if state == null:
		return is_all_scenes_unlocked()
	else:
		return bool(state)


func is_all_scenes_unlocked() -> bool:
	return scene_progress.get(UNLOCK_ALL_KEY, false)


func lock_scene(scene_key: String) -> bool:
	return _set_scene_progress_state(scene_key, false)


func unlock_scene(scene_key: String):
	return _set_scene_progress_state(scene_key, true)


func lock_all_scenes():
	scene_progress = {}
	md5 = compute_md5()

func unlock_all_scenes():
	scene_progress = {}
	scene_progress[UNLOCK_ALL_KEY] = true
	md5 = compute_md5()

func _set_scene_progress_state(scene_key: String, unlocked: bool) -> bool:
	if Game.is_scene_key_valid(scene_key):
		scene_progress[scene_key] = unlocked
		md5 = compute_md5()
		return true
	else:
		return false

func compute_md5() -> String:
	return _data.md5_text()

func migrate():
	match version:
		1:
			md5 = compute_md5()
			version = CURRENT_VERSION
		_:
			md5 = compute_md5()
			version = CURRENT_VERSION


func save_liked_comment(uid: String):
	if not liked_comments.has(uid):
		liked_comments.append(uid)


func save_shared_post(uid: String):
	if not shared_posts.has(uid):
		shared_posts.append(uid)


func save_board_cleared(scene):
	if not boards_cleared.has(scene):
		boards_cleared.append(scene)

	if boards_cleared.size() == 5:
		Game.dist_platform.unlock_achievement("ACH_HEAD_ARMOR")
