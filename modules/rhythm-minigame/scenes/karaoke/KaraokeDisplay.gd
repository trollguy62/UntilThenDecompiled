extends Node

@onready var idle := $Idle
@onready var sing := $Sing
@onready var scoring := $Scoring

# TODO: Instead of referencing these, encapsulate behavior
@onready var logo = $Logo

@onready var song_info := $Idle/SongInfo
@onready var popular_songs := $Idle/PopularSongs

@onready var rhythm_anchor := $Sing/RhythmAnchor
@onready var song_queue := $Sing/SongQueue
@onready var top_bar_input := $Sing/SongInputTopBar
@onready var sing_initial_screen := $Sing/InitialScreen

@onready var score_screen := $Scoring/ScoreScreen

var display_size: Vector2:
	set(v):
		$Background.display_size = v
		display_size = v
