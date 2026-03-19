extends PanelContainer

signal exited

const HIDDEN_TEXT = "  ? ? ?"

const TOPICS := {
	"CW_TOPIC_START": {},
	"CW_TOPIC_SOUNDS": {
		"CW_TOPIC_SOUNDS_1": {},
		"CW_TOPIC_SOUNDS_2": {},
	},
	"CW_TOPIC_HOMOPHOBIA": {
		"CW_TOPIC_HOMOPHOBIA_1": {},
		"CW_TOPIC_HOMOPHOBIA_2": {},
	},
	"CW_TOPIC_LONELINESS": {
		"CW_TOPIC_LONELINESS_1": {},
		"CW_TOPIC_LONELINESS_2": {},
	},
	"CW_TOPIC_DYSFAM": {
		"CW_TOPIC_DYSFAM_1": {
			"CW_TOPIC_DYSFAM_1_1": {},
		},
		"CW_TOPIC_DYSFAM_2": {},
	},
	"CW_TOPIC_GRIEF": {
		"CW_TOPIC_GRIEF_STAGES": {
			"CW_TOPIC_GRIEF_STAGES_1": {},
			"CW_TOPIC_GRIEF_STAGES_2": {},
		},
		"CW_TOPIC_GRIEF_NEGCOPE": {
			"CW_TOPIC_GRIEF_NEGCOPE_1": {},
			"CW_TOPIC_GRIEF_NEGCOPE_2": {},
			"CW_TOPIC_GRIEF_NEGCOPE_3": {},
			"CW_TOPIC_GRIEF_NEGCOPE_4": {},
		},
		"CW_TOPIC_GRIEF_DISAPPEAR": {
			"CW_TOPIC_GRIEF_DISAPPEAR_1": {},
			"CW_TOPIC_GRIEF_DISAPPEAR_2": {},
		},
		"CW_TOPIC_GRIEF_DEATH": {
			"CW_TOPIC_GRIEF_DEATH_CAUSED_BY": {
				"CW_TOPIC_GRIEF_DEATH_CAUSED_BY_1": {},
				"CW_TOPIC_GRIEF_DEATH_CAUSED_BY_2": {},
				"CW_TOPIC_GRIEF_DEATH_CAUSED_BY_3": {
					"CW_TOPIC_GRIEF_DEATH_CAUSED_BY_3_1": {},
				},
			},
			"CW_TOPIC_GRIEF_DEATH_1": {},
			"CW_TOPIC_GRIEF_DEATH_2": {},
		},
	},
	"CW_TOPIC_DV": {
		"CW_TOPIC_DV_1": {
			"CW_TOPIC_DV_1_1": {},
			"CW_TOPIC_DV_1_2": {},
		},
		"CW_TOPIC_DV_2": {},
	},
	"CW_SUICIDE": {
		"CW_SUICIDE_1": {},
		"CW_SUICIDE_2": {},
	},
}

const ASIDES := {
	"CW_TOPIC_DV": "CW_ASIDE_DV",
	"CW_SUICIDE": "CW_ASIDE_SUICIDE",
}

const ASIDE_TWEEN_DUR := 0.1

@export var fade_duration = 1.0

@onready var main_container = $VBoxContainer
@onready var tree = $VBoxContainer/HBoxContainer/Tree
@onready var aside_label = $VBoxContainer/HBoxContainer/Aside


func _ready():
	set_process(false)
	main_container.modulate.a = 0
	
	var root = tree.create_item()
	_populate_item(root, TOPICS)
	
	tree.item_selected.connect(_on_tree_item_selected)
	tree.item_activated.connect(_on_tree_item_activated)


func start():
	var tween = create_tween()
	tween.tween_property(main_container, "modulate:a", 1, fade_duration)
	await tween.finished
	tree.grab_focus()
	set_process(true)


func _input(ev: InputEvent):
	# Prevent left stick from navigating the tree. It's too fast.
	if ev is InputEventJoypadMotion and ev.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y]:
		get_viewport().set_input_as_handled()


func _process(_delta):
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("ui_cancel"):
		set_process(false)
		_exit()


func _exit():
	tree.release_focus()
	var tween = create_tween().set_parallel()
	tween.tween_property($VBoxContainer, "modulate:a", 0, fade_duration)
	await tween.finished
	exited.emit()


func _populate_item(parent: TreeItem, topics: Dictionary, root_topic: String = "") -> void:
	for topic in topics:
		var rt = topic if root_topic == "" else root_topic
		var child: TreeItem = tree.create_item(parent)
		child.collapsed = true
		
		child.set_text(0, HIDDEN_TEXT)
		child.set_custom_color(0, Color(Color.WHITE, 0.4))
		child.set_metadata(0, [topic, rt])
		
		if topic == "CW_TOPIC_START":
			_reveal(child)
			tree.set_selected(child, 0)
		else:
			_populate_item(child, topics[topic], rt)


func _on_tree_item_selected() -> void:
	_reveal(tree.get_selected())


func _reveal(item: TreeItem) -> void:
	var metadata: Array = item.get_metadata(0)
	var topic: String = metadata[0]
	var root_topic: String = metadata[1]
	
	if topic != "":
		item.set_text(0, "  " + tr(topic))
		item.set_custom_color(0, Color.WHITE)
		item.set_metadata(0, ["", root_topic])
	
	if root_topic in ASIDES:
		_set_aside_text(tr(ASIDES[root_topic]))
	else:
		_set_aside_text("")


func _on_tree_item_activated() -> void:
	var item: TreeItem = tree.get_selected()
	item.collapsed = not item.collapsed


func _set_aside_text(text: String) -> void:
	if aside_label.text == text:
		return
	
	if aside_label.text != "":
		var tween = create_tween()
		tween.tween_property(aside_label, "modulate:a", 0, ASIDE_TWEEN_DUR)
		await tween.finished
	
	aside_label.modulate.a = 0
	aside_label.text = text
	
	if text == "":
		return
	
	var tween = create_tween()
	tween.tween_property(aside_label, "modulate:a", 1, ASIDE_TWEEN_DUR)
	await tween.finished
