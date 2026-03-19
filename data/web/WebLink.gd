var url: String:
	get: return url
var protocol: String:
	get: return url.substr(0, url.find("://") + 3)
var domain: String:
	get: return Utils.array_get(components, 0, "null")
var components: Array:
	get: return components
var query_params: Dictionary:
	get: return query_params


func _init(url: String, components: Array, query_params: Dictionary):
	self.url = url
	self.components = components
	self.query_params = query_params


func url_without_protocol():
	return url.trim_prefix(protocol)


func trimmed_url() -> String:
	var i = url.find("?")
	if i < 0:
		i = url.length()
	return url.substr(0, i).trim_suffix("/")


func get_store_ref() -> String:
	return trimmed_url() + "/."
