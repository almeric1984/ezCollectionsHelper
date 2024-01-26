local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
MessageHandler = __TS__Class()
MessageHandler.name = "MessageHandler"
function MessageHandler.prototype.____constructor(self)
end
function MessageHandler.prototype.Send(self, player, message, prefix)
    local opcode = 150
    local chatType = 0
    local language = 4294967295
    message = ((prefix .. "\t") .. message) .. "\0"
    local packetSize = self:CalculatePacketSize(message)
    local packet = CreatePacket(opcode, packetSize)
    packet:WriteUByte(chatType)
    packet:WriteULong(language)
    packet:WriteGUID(0)
    packet:WriteULong(0)
    packet:WriteGUID(player:GetGUID())
    packet:WriteULong(#message)
    packet:WriteString(message)
    packet:WriteUByte(0)
    player:SendPacket(packet)
end
function MessageHandler.prototype.CalculatePacketSize(self, message)
    local headerSize = 8 + 32 + 16 + 64 / 8
    local playerGuidSize = 64 / 8
    local messageSize = message:len()
    return headerSize + playerGuidSize + messageSize
end
