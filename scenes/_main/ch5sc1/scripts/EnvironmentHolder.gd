extends Node

# This script literally just holds an Environment instance to better animate its properties
#	(and only *its* properties) with AnimationPlayer instead of animating properties through
#	WorldEnvironment where the current Environment (whatever it is) would be the one being animated.

@export var environment: Environment
