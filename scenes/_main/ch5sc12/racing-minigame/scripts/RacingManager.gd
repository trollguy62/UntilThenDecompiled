extends Node3D

const CarReplayController = preload("CarReplayController.gd")

signal game_ended(result)

@onready var path = $PathProjectors
@onready var placement_update_timer = $RankingUpdateTimer
var player_path_list = []
var non_player_cars = []
var lap_time_limit
var total_laps
var players_completed = 0
var game_end = false
var mark_complete = false
var cathy_complete = false


func init():
	placement_update_timer.timeout.connect(_on_ranking_timer_timeout)

	for i in path.get_children():
		if i is PathFollow3D:
			player_path_list.append(i)
			i.set_time_limit(lap_time_limit)
			i.set_total_laps(total_laps)
			i.race_finished.connect(_on_player_completed)
			i.time_out.connect(_on_player_completed)

	for car in $Players.get_children():
		if car is CarReplayController:
			non_player_cars.append(car)


func pre_start_race():
	for car in non_player_cars:
		car.start()


func start_race():
	for player in player_path_list:
		player.start_race()


func set_time_limit(time):
	lap_time_limit = time


func set_total_laps(val):
	total_laps = val


func pause_game(is_paused):
	for player in player_path_list:
		player.allow_movement(!is_paused)
		player.set_pause_time(is_paused)


func _on_ranking_timer_timeout():
	if game_end:
		return
	player_path_list.sort_custom(compare_progress)

	for i in player_path_list.size():
		var rank = i + 1
		player_path_list[i].set_rank(rank)


func _on_player_completed(player_name):
#	if players_completed == player_path_list.size():
	if player_name == "MRK":
		mark_complete = true

	if player_name == "CTH":
		cathy_complete = true

	if mark_complete and cathy_complete:
		end_game()


func end_game():
	if game_end:
		return

	game_end = true

	var result = []
	for i in player_path_list.size():
		var player = player_path_list[i]
		var player_result = {"name": player.player_name, "time": player.get_time_finished()}
		result.append(player_result)

	game_ended.emit(result)


func compare_progress(a, b):
	if a.has_finished or b.has_finished:
		return false
	if a.get_race_progress() > b.get_race_progress():
		return true
	return false
