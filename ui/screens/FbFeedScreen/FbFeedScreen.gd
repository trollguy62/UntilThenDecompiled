extends "../Screen.gd"

const FbStatus = preload("res://data/fb/FbStatus.gd")
const FbStatusView = preload("res://ui/components/FbStatus/FbStatus.tscn")

@onready var scroll = $Scroll
@onready var menu_bar = $MenuBar
@onready var status_list = $Scroll/Margin/StatusList

var status_uids: Array = []
var hide_back_btn := false

func _ready():
	self.bg_color = Constants.COLOR_BG_FB
	menu_bar.hide_back_btn = true

	for uid in status_uids:
		var status_json = Store.get_value("fb://posts/" + uid)
		var status = FbStatus.new(uid, status_json)
		var status_view = FbStatusView.instantiate()
		status_view.status = status
		status_list.add_child(status_view)

	var footer = Utils.make_empty_panel_container()
	status_list.add_child(footer)


func _before_show():
	super._before_show()
	menu_bar.disable_back_btn = true

func _after_show():
	super._after_show()
	menu_bar.disable_back_btn = false

func _before_hide():
	super._before_hide()
	menu_bar.disable_back_btn = true


func _process(delta):
	if hide_back_btn:
		return

	if menu_bar.hide_back_btn:
		if scroll.get_max_scroll_pos().length() > 0 and scroll.get_scroll_unit_position().y > 0.5:
			menu_bar.hide_back_btn = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_up") and get_viewport().gui_get_focus_owner() == null and is_visible_in_tree():
		$MenuBar.grab_focus()
