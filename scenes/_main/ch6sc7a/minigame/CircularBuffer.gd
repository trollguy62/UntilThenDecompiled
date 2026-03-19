extends RefCounted

var buffer: Array = []
var size: int:
	set(v):
		buffer.resize(v)
		size = v
	get:
		return buffer.size()

var read_idx: int = 0
var write_idx: int = 0

func put(item):
	if (write_idx + 1) % size == read_idx:
		pass

	buffer[write_idx] = item
	write_idx = (write_idx + 1) % size
	return true

func retrive() -> Variant:
	if read_idx == write_idx:
		#empty
		return null

	var ret = buffer[read_idx]
	read_idx = (read_idx + 1) % size
	return ret
