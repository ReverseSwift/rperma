rperma.config = {}

rperma.config.durabilityloss = 1

rperma.config.previewstyle = 1

rperma.config.customcheck = function(ply)
	return true -- change true to anything you want, checked on PlayerSpawn, for custom things like ply:InEvent()
end

rperma.config.categories = {
	{"Knives", Color(0, 195, 165, 10)},
	{"Guns", Color(0, 165, 240, 10)},
}

rperma.config.weapons = {
	["tfa_starwars_incendiary"] = {
		price = 250000,
		category = "Knives",
	},
	["tfa_starwars_shock"] = {
		price = 250000,
		category = "Knives",
	},
	["weapon_752_bowcaster"] = {
		price = 250000,
		category = "Knives",
	},
	["weapon_752_dh17"] = {
		price = 250000,
		category = "Knives",
	},	
	["weapon_752_kotor_blaster_rifle"] = {
		price = 250000,
		category = "Knives",
	},
	["weapon_752_kyd21"] = {
		price = 250000,
		category = "Knives",
	},
	["tfa_kotor_br_2"] = {
		price = 250000,
		category = "Knives",
	},
	["tfa_swch_dc15a"] = {
		price = 250000,
		category = "Knives",
	},	
	["tfa_swch_e5"] = {
		price = 250000,
		category = "Guns",
	},
	["tfa_sw_cisshot"] = {
		price = 250000,
		category = "Guns",
	},
	["tfa_swch_de10"] = {
		price = 250000,
		category = "Guns",
	},
	["tfa_sw_dual_kyd21"] = {
		price = 250000,
		category = "Guns",
	},	
	["tfa_752_dlt19"] = {
		price = 250000,
		category = "Guns",
	},
	["tfa_dh17"] = {
		price = 250000,
		category = "Guns",
	},
	["tfa_dc17m_shotgun"] = {
		price = 250000,
		category = "Guns",
	},
	["tfa_swch_dc17m_br"] = {
		price = 250000,
		category = "Guns",
	},	
}