extends VBoxContainer

const FbComment = preload("res://data/fb/FbComment.gd")
const FbAtom = preload("res://data/fb/FbAtom.gd")
const FbCommentView = preload("res://ui/components/FbComment/FbComment.tscn")

@export var max_comments = -1

var atom: FbAtom:
	set = _set_atom,
	get = _get_atom

var open_replies_func: Callable


func _set_atom(value):
	if atom:
		atom.comments_changed.disconnect(_update)

	atom = value
	atom.comments_changed.connect(_update)

	for child in get_children():
		remove_child(child)
		child.queue_free()

	_update()
	add_child(Utils.make_empty_panel_container())


func _get_atom():
	return atom


func _update():
	if atom == null or max_comments == 0:
		return

	var comments = atom.ordered_comments()
	var count = comments.size() if max_comments < 0 else max_comments

	for i in range(count):
		var comment: FbComment = comments[i]
		if not has_node(comment.uid):
			_add_comment(comment, i)


func _add_comment(comment: FbComment, idx: int):
	var view = FbCommentView.instantiate()
	view.name = comment.uid
	view.comment = comment

	if open_replies_func:
		view.open_replies_func = open_replies_func

	add_child(view)
	move_child(view, idx)


func get_comment_view(uid: String):
	return get_node(uid)
