util.AddNetworkString("rperma_openmenu")
util.AddNetworkString("rperma_purchase")
util.AddNetworkString("rperma_equip")
util.AddNetworkString("rperma_success")

rperma.mysqlinfo = {
	["host"] = "0.0.0.0",
	["username"] = "admin_username",
	["password"] = "admin_password",
	["database"] = "database_name",
	["port"] = 3306,
}

rperma.tables = {
	["perma"] = "rperma_purchases",
}

rperma.playerpurchases = rperma.playerpurchases or {}

if not rperma.mysql then
	require( "mysqloo" )

	local db = mysqloo.connect(rperma.mysqlinfo.host, rperma.mysqlinfo.username, rperma.mysqlinfo.password, rperma.mysqlinfo.database, rperma.tables.port)

	db:setAutoReconnect(true)
	db:setMultiStatements(true)

	function db:onConnected()
		MsgC(Color(0, 195, 165), "RPerma | ", Color(255, 255, 255), "Database has connected! \n")
	end

	function db:onConnectionFailed( err )
		MsgC(Color(255, 100, 100), "RPerma | ", Color(255, 255, 255), "Database connection failed! \n")
		MsgC("Error:", err)
	end

	db:connect()

	rperma.mysql = db
end

function rperma:Query(action, cb)
	cb = cb or function() end

	local query = self.mysql:query(action)

	query.onSuccess = function(_, data)
		cb(true, data)
	end

	query.onError = function()
		cb(false, nil)
	end

	query:start()
end

function rperma:InitData()
	self:Query("CREATE TABLE IF NOT EXISTS `"..self.tables.perma.."` (`steamid` VARCHAR(20) PRIMARY KEY, `purchases` VARCHAR(2000))")
end

function rperma:InitPly(ply)
	if not self.playerpurchases[ply:SteamID64()]  then
		self:Query("SELECT * FROM `"..self.tables.perma.."` WHERE `steamid` LIKE '"..ply:SteamID64().."';", function(success, data)
			if not success then return end

			if #data > 0 then
				local a = data[1]

				self.playerpurchases[ply:SteamID64()] = util.JSONToTable(a.purchases)
			end
		end)
	end
end

function rperma:DiscPly(ply)
	if self.playerpurchases[ply:SteamID64()] then
		self.playerpurchases[ply:SteamID64()] = nil
	end
end

function rperma:SaveInfo(steam64)
	self:Query("SELECT * FROM `"..self.tables.perma.."` WHERE `steamid` LIKE '"..steam64.."'", function(success, data)
		if not success then return end

		if #data > 0 then
			self:Query("UPDATE `"..self.tables.perma.."` SET purchases = '"..util.TableToJSON(self.playerpurchases[steam64]).."' WHERE `steamid` LIKE '"..steam64.."'")
		else
			self:Query("INSERT INTO `"..self.tables.perma.."` (`steamid`, `purchases`) VALUES ('"..steam64.."', '"..util.TableToJSON(self.playerpurchases[steam64]).."')")
		end
	end)
end

function rperma:PurchaseItem(ply)
	if not IsValid(ply) then return end

	local ent = net.ReadEntity()

	if not IsValid(ent) then return end
	if ent:GetClass() != "reverse_perma_npc" or ent:GetPos():Distance(ply:GetPos()) > 100 then return end

	local itemid = net.ReadString()
	local steam64 = ply:SteamID64()

	if not self.config.weapons[itemid] then return end

	local iteminfo = self.config.weapons[itemid]

	if not ply:canAfford(iteminfo.price) then
		DarkRP.notify(ply, 1, 4, "You cannot afford this!")
		return
	end

	if self.playerpurchases[steam64] and self.playerpurchases[steam64][itemid] then
		DarkRP.notify(ply, 1, 4, "You already own this item!")
		return
	end

	ply:addMoney(iteminfo.price * -1)
	DarkRP.notify(ply, 1, 4, "You purchased an item!")

	self.playerpurchases[steam64] = self.playerpurchases[steam64] or {}

	self.playerpurchases[steam64][itemid] = {
		["equipped"] = 1,
		["durability"] = 100,
	}

	ply:Give(itemid)

	self:SaveInfo(steam64)

	net.Start("rperma_success")
	net.Send(ply)
end

function rperma:Equip(ply)
	if not IsValid(ply) then return end

	local ent = net.ReadEntity()

	if not IsValid(ent) then return end
	if ent:GetClass() != "reverse_perma_npc" or ent:GetPos():Distance(ply:GetPos()) > 100 then return end

	local itemid = net.ReadString()
	local equip = net.ReadInt(3)
	local steam64 = ply:SteamID64()

	if not self.playerpurchases[steam64] then return end
	if not self.playerpurchases[steam64][itemid] then return end
	if equip < 0 or equip > 1 then return end

	self.playerpurchases[steam64][itemid].equipped = equip

	if equip == 1 then
		DarkRP.notify(ply, 4, 1, "Equipped item")
		ply:Give(itemid)
	else
		if ply:HasWeapon(itemid) then
			ply:StripWeapon(itemid)
		end
		DarkRP.notify(ply, 4, 1, "Unequipped item")
	end
end

function rperma:RemoveItem(ply, k)
	if not IsValid(ply) then return end

	local itemid = k
	local steam64 = ply:SteamID64()

	if not self.config.weapons[itemid] then return end

	local iteminfo = self.config.weapons[itemid]

	if self.playerpurchases[steam64] and !self.playerpurchases[steam64][itemid] then return end

	DarkRP.notify(ply, 1, 4, "You lost item as it's lost all its durability")

	self.playerpurchases[steam64][itemid] = nil

	self:SaveInfo(steam64)
end

function rperma:PlayerDeath(ply)
	local steam64 = ply:SteamID64()

	if not self.playerpurchases[steam64] then return end

	local reductionchance = math.random(1, 100)

	if reductionchance < 50 then
		for k, v in pairs(self.playerpurchases[steam64]) do
			if v.equipped == 1 then
				v.durability = v.durability - self.config.durabilityloss
				if v.durability <= 0 then
					self:RemoveItem(ply, k)
				end
			end
		end
	end
end

function rperma:GiveItems(ply)
	if self.playerpurchases[ply:SteamID64()] then
		for k, v in pairs(self.playerpurchases[ply:SteamID64()]) do
			if v.equipped == 1 then
				ply:Give(k)
			end
		end
	end
end

-- Hooks and stuff

hook.Add("Initialize", "rperma_initdb", function()
	rperma:InitData()
end)

hook.Add("PlayerInitialSpawn", "rperma_initply", function(ply)
	rperma:InitPly(ply)
end)

hook.Add("PlayerDisconnected", "rperma_discply", function(ply)
	rperma:DiscPly(ply)
end)

hook.Add("PlayerDeath", "rperma_plydeath", function(ply)
	rperma:PlayerDeath(ply)
end)

hook.Add("PlayerSpawn", "rperma_plyspawn", function(ply)
	timer.Simple(0.5, function()
		rperma:GiveItems(ply)
	end)
end)

net.Receive("rperma_purchase", function(_, ply)
	rperma:PurchaseItem(ply)
end)

net.Receive("rperma_equip", function(_, ply)
	rperma:Equip(ply)
end)

hook.Add("canDropWeapon", "rperma_candropwep", function(ply, wep)
	if IsValid(wep) and IsValid(ply) and ply:Alive() and rperma.playerpurchases[ply:SteamID64()] and rperma.playerpurchases[ply:SteamID64()][wep:GetClass()] then
		return false
	end
end)
