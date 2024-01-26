/** @customName CreatePacket */
declare function CreatePacketNoSelf(this: void, opcode: number, size: number): WorldPacket;
class MessageHandler {
  
    public Send(player: Player, message : string, prefix : string){
      const opcode = 0x096; // @hex;
      let chatType = 0x00 // ChatType 
      let language = 0xFFFFFFFF // Language 
      message = prefix + '\t' + message + '\0'
      let packetSize = this.CalculatePacketSize(message)
      let packet = CreatePacketNoSelf(opcode,packetSize);
      packet.WriteUByte(chatType)
      packet.WriteULong(language)
      packet.WriteGUID(0)
      packet.WriteULong(0)
      packet.WriteGUID(player.GetGUID())
      packet.WriteULong(message.length )
      packet.WriteString(message)
      packet.WriteUByte(0)
      player.SendPacket(packet)
    }

    CalculatePacketSize(message){
      let headerSize = 8 + 32 + 16 + 64 / 8 
      let playerGuidSize = 64 / 8 
      let messageSize = message.len()
      
      return headerSize + playerGuidSize + messageSize
    }

}