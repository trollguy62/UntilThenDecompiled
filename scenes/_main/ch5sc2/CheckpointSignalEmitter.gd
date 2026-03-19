extends Node

var skit: SkitContainer


func _skit_ready(skit: SkitContainer):
	assert(skit)
	self.skit = skit


func on_hallway_precheckpoint_reached():
	skit.emit_local("hallway_precheckpoint_reached")


func on_hallway_checkpoint_reached():
	skit.emit_local("hallway_checkpoint_reached")
