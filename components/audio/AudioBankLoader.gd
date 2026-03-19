@tool
extends Node
class_name AudioBankLoader

const BANKS_PATH = "res://addons/fmod/editor/resources/banks"

@export var bank_name = ""


func _ready():
	assert(not bank_name.is_empty())


func as_studio_bank_loader() -> StudioBankLoader:
	var bank := get_bank_asset()
	if bank == null:
		return null

	var loader := StudioBankLoader.new()
	loader.name = "StudioBankLoader"

	loader.load_on = RuntimeUtils.GAMEEVENT_ENTER_TREE
	loader.unload_on = RuntimeUtils.GAMEEVENT_EXIT_TREE
	loader.num_banks = 1
	loader.set("bank_0", get_bank_asset())
	print(bank, loader)

	return loader


func get_bank_asset() -> BankAsset:
	for f in Utils.files_in_dir(BANKS_PATH):
		var b = load(BANKS_PATH+"/"+f) as BankAsset
		if b.name == bank_name:
			return b

	printerr("Bank %s not found" % bank_name)
	return null
