extends Node

const WebLink = preload("res://data/web/WebLink.gd")
const WebPage = preload("res://ui/screens/Web/WebPage.gd")
const WebPageModel = preload("res://data/web/WebPageModel.gd")

var url_regex = RegEx.new()
var query_params_regex = RegEx.new()
var dinogame_high_score: int:
	set(value): Store.set_config("https", "dinogame_high_score", value)
	get: return Store.get_config("https", "dinogame_high_score", 0)


func _ready():
	url_regex.compile("https?:\\/\\/([^?]+)(?:\\?(.+))?")
	query_params_regex.compile("([^&]+)=([^&]+)")


func _get_query_params(params: String) -> Dictionary:
	var query_params = {}
	var matches = query_params_regex.search_all(params)

	for m in matches:
		var key = m.strings[1]
		var value = m.strings[2]
		query_params[key] = value

	return query_params


func make_web_link(url: String):
	var url_match = WebUtils.url_regex.search(url)
	if url_match == null:
		return

	var components = url_match.strings[1].split("/")
	var query_params = {}

	if url_match.strings.size() >= 3:
		var params = url_match.strings[2]
		query_params = _get_query_params(params)

	return WebLink.new(url, components, query_params)


func get_page(link):
	if link is String:
		link = make_web_link(link)
	if not link is WebLink:
		return

	var store_ref = link.get_store_ref()
	var dict = Store.get_value(store_ref)
	if not "scene" in dict:
		return

	var packed_page = load(dict.scene)
	if not packed_page is PackedScene:
		return

	var page = packed_page.instantiate()
	if page is WebPage:
		page.link = link
		return page


func get_page_model(link):
	if link is String:
		link = make_web_link(link)
	if not link is WebLink:
		return

	var store_ref = link.get_store_ref()
	var dict = Store.get_value(store_ref)
	if dict and not dict.is_empty():
		return WebPageModel.new(link, dict)
