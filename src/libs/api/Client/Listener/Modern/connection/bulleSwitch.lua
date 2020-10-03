local enum = require("api/enum")

-- Optimization --
local string_split = string.split
------------------

local onBulleSwitch = function(self, packet, connection, identifiers)
	local serverTimestamp = packet:read32()

	local uid = packet:read32()
	local pid = packet:read32()

	local bulleIp = packet:readUTF()

	enum.setting.port = string_split(packet:readUTF(), '-', true)

	local oldBulle = self.bulleConnection

	self.bulleConnection = connection:new("bulle", self.event)
	self.bulleConnection:connect(bulleIp, enum.setting.port[self.mainConnection.portIndex])

	self.bulle.event:once("_socketConnection", function()
		if oldBulle then
			oldBulle:close()
		end

		self.bulleConnection:send(enum.identifier.bulleConnection,
			byteArray:new():write32(serverTimestamp):write32(uid):write32(pid))

		--[[@
			@name switchBulleConnection
			@desc Triggered when the bulle connection is switched.
			@param bulleId<int> The ID of the new bulle.
			@param bulleIp<string> The IP of the new bulle.
			@param serverTimestamp<int> The timestamp of the server.
		]]
		self.event:emit("switchBulleConnection", bulleId, bulleIp, serverTimestamp)
	end)
end

return { 44, 1, onBulleSwitch }