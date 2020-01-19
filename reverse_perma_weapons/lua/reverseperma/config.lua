-[[
Commissioned By: Reverse
Produced By: Tasid
--]]

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
	["weapon_ak472"] = {
		price = 250000,
		category = "Knives",
	},
	
}
