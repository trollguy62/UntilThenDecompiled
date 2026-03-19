extends Node

const FbQuark = preload("res://data/fb/FbQuark.gd")
const FbAtom = preload("res://data/fb/FbAtom.gd")
const FbStatus = preload("res://data/fb/FbStatus.gd")
const FbProfile = preload("res://data/fb/FbProfile.gd")
const FbPage = preload("res://data/fb/FbPage.gd")
const FbGroup = preload("res://data/fb/FbGroup.gd")
const FbComment = preload("res://data/fb/FbComment.gd")
const FbCommentModal = preload("res://ui/modals/FbCommentModal/FbCommentModal.tscn")

const TAG_TYPE_MAP = {"u": "profiles", "p": "pages", "g": "groups"}

var _member_cache = {}
var _member_tag_regex = RegEx.new()
var _hashtag_regex = RegEx.new()


func _ready():
	_member_tag_regex.compile("\\@(?:([ugp])\\:)?(\\w+)")
	_hashtag_regex.compile("\\#\\w+")


func get_member(ref: String):
	assert(ref.begins_with("fb://"))
	if _member_cache.has(ref):
		return _member_cache[ref]

	var json = Store.get_value(ref)
	if json == null:
		return

	var ref_delim = ref.split("/")
	var uid = ref_delim[ref_delim.size() - 1]
	var member

	if ref.begins_with("fb://profiles"):
		member = FbProfile.new(uid, json)
	elif ref.begins_with("fb://pages"):
		member = FbPage.new(uid, json)
	elif ref.begins_with("fb://groups"):
		member = FbGroup.new(uid, json)

	if member != null:
		_member_cache[ref] = member

	return member


func clear_cache():
	_member_cache = {}


### BBcode transforms ###
func transform_bbcode_text(bbcode_text: String) -> String:
	bbcode_text = _transform_member_tags(bbcode_text)
	bbcode_text = _transform_hashtags(bbcode_text)
	return Utils.stylize_bbcode_urls(bbcode_text, "[b]", "[/b]")


func _transform_member_tags(bbcode_text: String) -> String:
	var matches = _member_tag_regex.search_all(bbcode_text)

	for m in matches:
		var type_char = m.strings[1]
		var uid = m.strings[2]

		if type_char.is_empty():
			type_char = "u"

		var type = TAG_TYPE_MAP[type_char]
		var member = get_member("fb://%s/%s" % [type, uid])

		if member:
			var repl = "[url=fb://%s/%s]%s[/url]" % [type, uid, member.name]
			bbcode_text = bbcode_text.replace(m.strings[0], repl)

	return bbcode_text


func _transform_hashtags(bbcode_text: String) -> String:
	var m = _hashtag_regex.search(bbcode_text)

	while m:
		var i0 = m.get_start()
		var i1 = m.get_end()
		var hashtag = "#[b]%s[/b]" % m.strings[0].trim_prefix("#")

		bbcode_text = bbcode_text.substr(0, i0) + hashtag + bbcode_text.substr(i1)
		m = _hashtag_regex.search(bbcode_text)

	return bbcode_text


func get_status_author_title(status: FbStatus, member_name: String) -> String:
	var ret = "[url=%s]%s[/url]" % [status.author_ref, member_name]
	if not status.action.is_empty():
		ret += " " + status.action
	return transform_bbcode_text(ret)


func get_status_author_subtitle(status: FbStatus, use_sponsored = true) -> String:
	if use_sponsored and status.sponsored:
		return tr("FB_UTILS_SPONSORED")
	return timestamp_str(status.timestamp)


func count_and_noun(count: int, noun: String, irreg_plural: String = "") -> String:
	return "%s %s" % [Utils.commaify_int(count), Utils.pluralize(count, noun, irreg_plural)]


func count_and_noun_tr(count: int, message_prefix: String) -> String:
	if count == 1:
		return tr(message_prefix + "_1")
	else:
		return tr(message_prefix + "_N") % Utils.commaify_int(count)


func reveal_comment_modal(atom: FbAtom):
	var navigator = Service.of(Service.NAVIGATOR)
	if navigator:
		var modal = FbCommentModal.instantiate()
		modal.atom = atom
		navigator.reveal_modal(modal)


func timestamp_str(timestamp: int) -> String:
	# TODO so much can be reused from here sometime else
	var now = Game.time
	var diff = now - timestamp
	if diff < 0:
		return "invalid"

	var dt1 = Time.get_datetime_dict_from_unix_time(timestamp)
	var dt0 = Time.get_datetime_dict_from_unix_time(now)

	# From 24hr to 12hr
	var period = "AM" if dt1.hour < 12 else "PM"
	var hour = dt1.hour
	if hour == 0:
		hour = 12
	elif hour > 12:
		hour -= 12

	var time = "%d:%02d %s" % [hour, dt1.minute, period]
	var month_short = tr(Constants.MONTHS_SHORT[dt1.month - 1])

	if dt1.year != dt0.year:
		if Game.config.is_locale_non_latin():
			return "%d年%d月%d日 %s" % [dt1.year, dt1.month, dt1.day, time]
		else:
			return "%d %s %d at %s" % [dt1.day, month_short, dt1.year, time]

	var yesterday = Time.get_datetime_dict_from_unix_time(now - 86400)
	var is_yesterday = yesterday.month == dt1.month and yesterday.day == dt1.day
	var is_today = dt1.month == dt0.month and dt1.day == dt0.day

	if is_yesterday:
		return tr("FB_UTILS_YESTERDAY") % [time]
	if not is_today:
		if Game.config.is_locale_non_latin():
			return "%d月%d日 %s" % [dt1.month, dt1.day, time]
		else:
			return "%d %s at %s" % [dt1.day, month_short, time]

	if diff < 60:
		return tr("FB_UTILS_JUST_NOW")
	elif 60 <= diff and diff < 3600:
		if Game.config.is_locale_non_latin():
			return "%s%s" % [Utils.commaify_int(diff/60), tr("FB_UTILS_MINUTES")]
		else:
			return count_and_noun(diff / 60, "min")

	if Game.config.is_locale_non_latin():
		return "%s%s" % [Utils.commaify_int(diff/3600), tr("FB_UTILS_HOURS")]
	else:
		return count_and_noun(diff / 3600, "hr")


func get_ordered_comments(comments: Dictionary, displayed_only = true) -> Array:
	var ord_comments = comments.values()

	if displayed_only:
		ord_comments = ord_comments.filter(func(c): return c.is_displayed())

	ord_comments.sort_custom(func(c1, c2): return c1.timestamp < c2.timestamp)
	return ord_comments


func get_choice_comments(comments: Dictionary) -> Array:
	var choices = comments.values()
	return choices.filter(func(c): return c.is_choice())


### FbStatus content view creator ###
const TextureRectButton = preload("res://ui/components/TextureRectButton/TextureRectButton.tscn")
const PictureGridView = preload("res://ui/components/PictureGrid/PictureGrid.tscn")
const WebPageModel = preload("res://data/web/WebPageModel.gd")
const FbShareView = preload("res://ui/components/FbShare/FbShare.tscn")
const FbLinkView = preload("res://ui/components/FbLink/FbLink.tscn")
const FbVideoView = preload("res://ui/components/FbVideo/FbVideo.tscn")


func make_content_view(status: FbStatus):
	var content_type = status.content_type
	var content = status.content
	var view

	match content_type:
		FbStatus.CONTENT_TYPE_PICTURE:
			view = TextureRectButton.instantiate()
			view.picture = content.picture_ref
			view.alt_route = "fb://picture"
			view.alt_route_payload = {"atom": status}
			view.fit_width = true

		FbStatus.CONTENT_TYPE_ALBUM:
			var album_pics: Array = content
			var entries = []
			var count = min(5, album_pics.size())

			for i in range(count):
				entries.append(
					{
						"picture_ref": album_pics[i].picture_ref,
						"alt_route": "fb://album",
						"alt_route_payload": {"status": status, "scroll_to": i}
					}
				)

			view = PictureGridView.instantiate()
			view.entries = entries

		FbStatus.CONTENT_TYPE_VIDEO:
			view = FbVideoView.instantiate()
			view.status = status

		FbStatus.CONTENT_TYPE_LINK:
			view = FbLinkView.instantiate()
			view.page = content.page
			view.cta = content.cta

		FbStatus.CONTENT_TYPE_SHARE:
			var share_uid: String = content
			var status_json = Store.get_value("fb://posts/" + share_uid)
			view = FbShareView.instantiate()
			view.status = FbStatus.new(share_uid, status_json)

	return view
