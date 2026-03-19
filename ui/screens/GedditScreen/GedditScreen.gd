extends "res://ui/screens/Screen.gd"

const GedditPost = preload("res://ui/screens/GedditScreen/GedditPost.tscn")

@onready var subgeddit_label = $MenuBar/HBoxContainer/SubgedditLabel
@onready var post_container = $ScrollContainer/VBoxContainer/PostContainer
@onready var back_button = $MenuBar/HBoxContainer/BackButton

var post_id: String


func _ready():
	self.bg_color = Color(1, 1, 1, 0.9)

	var content = Store.get_value("geddit://posts/%s" % post_id)
	var root = GedditPost.instantiate()

	root.geddit_post = GedditPost
	root.post_id = post_id
	root.content = content

	subgeddit_label.text = "r/" + content.get("subgeddit", "")

	post_container.add_child(root)

func _before_show():
	super._before_show()
	back_button.disabled = true


func _after_show():
	super._after_show()
	get_tree().create_timer(1.0).timeout.connect(func(): back_button.disabled = false)

func _before_hide():
	super._before_hide()
	back_button.disabled = true
