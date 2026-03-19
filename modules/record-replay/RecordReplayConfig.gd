class_name RecordReplayConfig
extends Resource

enum Mode { NONE, RECORD, REPLAY }

@export var mode := Mode.NONE
@export var recording_path: String # source if replaying, dest if recording
@export var replay_auto_only := false
