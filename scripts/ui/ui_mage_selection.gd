extends HBoxContainer

@onready var game = get_node("/root/game")
@onready var mage_button_configs = {
	"fire": {
		"button": $mage_button_fire,
		"selected": $mage_button_fire/selected,
	}
}

var selected_mage_type: String = ""

func clear_selections():
	selected_mage_type = ""
	for key in mage_button_configs.keys():
		mage_button_configs[key]["selected"].visible = false

func _on_mage_button_fire_pressed():
	if selected_mage_type != "fire":
		selected_mage_type = "fire"
		mage_button_configs["fire"]["selected"].visible = true
		game.prepare_to_summon("fire")
	else:
		selected_mage_type = ""
		mage_button_configs["fire"]["selected"].visible = false
		game.prepare_to_summon("")

func _ready():
	clear_selections()
