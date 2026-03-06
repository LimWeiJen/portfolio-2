extends Label

func _ready():
	text = "© " + str(Time.get_date_dict_from_system()["year"]) + " limweijen. All rights reserved."
