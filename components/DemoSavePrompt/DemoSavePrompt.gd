extends Control

const Savegame = preload("res://data/Savegame.gd")
const InitialSettingsScreen = preload("res://ui/screens/Game/InitialSettingsScreen/InitialSettingsScreen.tscn")

@onready var animation_player = $AnimationPlayer
@onready var prompt = $Prompt


func _ready():
	prompt.answered.connect(_on_prompt_answered)
	animation_player.play("enter")


func _on_prompt_answered(state):
	if state:
		print("Demo migration: Accepted.")
		Game.skip_demo_save_flag = true
		
		if not Game._try_load_savegame(Game.get_demo_save_path()):
			print("Demo migration: Failed to load demo save. Loading default savegame...")
			Game.savegame = Savegame.new()
			Game.save_savegame()
		else:
			print("Demo migration: Demo save loaded.")
			_copy_demo_store()
			# If demo is finished, unlock and set to Ch2Sc1
			if Game.savegame.is_scene_unlocked("credits"):
				print("Demo migration: Credits was unlocked. Unlocking Ch2Sc1...")
				Game.savegame.unlock_scene("2.1")
				Game.savegame.current_scene_key = "2.1"
				Game.save_savegame()

		Game.change_scene_to(InitialSettingsScreen)
	else:
		print("Demo migration: Refused. Loading default savegame...")
		Game.savegame = Savegame.new()
		Game.save_savegame()
		Game.change_scene_to(InitialSettingsScreen)
	
	print("Demo migration: Done.")


func _copy_demo_store():
	var store_path = _join_paths(Game.get_demo_base_path(), "store")
	
	if not DirAccess.dir_exists_absolute(store_path):
		print("Demo migration: No store dir found. Aborting.")
		return

	var user_store_path = "user://store/"
	print("Demo migration: Store copy start.")

	var store_dir = DirAccess.open(store_path)
	var target_dir = DirAccess.open(user_store_path)
	#copy store files from the demo

	var subdirs = store_dir.get_directories()
	for subdir in subdirs:
		var subdir_path = _join_paths(store_path, subdir)
		var scene_dir = DirAccess.open(subdir_path)

		for filename in scene_dir.get_files():
			if filename != "state.json": #only need to check for state as per reqs
				continue
			
			print("Demo migration: Store copy - " + filename)
			
			var filepath = _join_paths(subdir_path, filename)
			var f = FileAccess.open(filepath, FileAccess.READ)
			
			var new_dir_path = _join_paths(user_store_path, subdir)
			DirAccess.make_dir_recursive_absolute(new_dir_path)
			DirAccess.copy_absolute(filepath, _join_paths(new_dir_path, filename))
	
	print("Demo migration: Store copy end.")


func _join_paths(a: String, b: String):
	return a.trim_suffix("/") + "/" + b.trim_suffix("/")
