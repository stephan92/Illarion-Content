require("handler.sendmessagetoplayer")
require("handler.createplayeritem")
require("questsystem.base")
module("questsystem.information_runewick_1.trigger21", package.seeall)

local QUEST_NUMBER = 621
local PRECONDITION_QUESTSTATE = 90
local POSTCONDITION_QUESTSTATE = 97

local NPC_TRIGGER_DE = "[Aa]lterslos"
local NPC_TRIGGER_EN = "[Aa]geless"
local NPC_REPLY_DE = "Genau, Elara erscheint oft als eine alterlose Frau und hier ein Spiegel als Belohnung. F�r die n�chste Aufgabe geht es zu den Grabsteinen beim Feuer des Triumph. Gefragt ist die Jahreszahl der angesprochenen Kampagne."
local NPC_REPLY_EN = "Exactly, Elara appears often as an ageless woman and here is a mirror as your reward. For your next task you have to go north to the tombstones at the Fire of Triumph and tell me the year of the compaign noted there."

function receiveText(npc, type, text, PLAYER)
    if ADDITIONALCONDITIONS(PLAYER)
    and PLAYER:getType() == Character.player
    and questsystem.base.fulfilsPrecondition(PLAYER, QUEST_NUMBER, PRECONDITION_QUESTSTATE) then
        if PLAYER:getPlayerLanguage() == Player.german then
            NPC_TRIGGER=string.gsub(NPC_TRIGGER_DE,'([ ]+)',' .*');
        else
            NPC_TRIGGER=string.gsub(NPC_TRIGGER_EN,'([ ]+)',' .*');
        end

        foundTrig=false
        
        for word in string.gmatch(NPC_TRIGGER, "[^|]+") do 
            if string.find(text,word)~=nil then
                foundTrig=true
            end
        end

        if foundTrig then
      
            npc:talk(Character.say, getNLS(PLAYER, NPC_REPLY_DE, NPC_REPLY_EN))
            
            HANDLER(PLAYER)
            
            questsystem.base.setPostcondition(PLAYER, QUEST_NUMBER, POSTCONDITION_QUESTSTATE)
        
            return true
        end
    end
    return false
end

function getNLS(player, textDe, textEn)
  if player:getPlayerLanguage() == Player.german then
    return textDe
  else
    return textEn
  end
end


function HANDLER(PLAYER)
    handler.sendmessagetoplayer.sendMessageToPlayer(PLAYER, "Gehe in den Norden zu der Stelle wo du vier Lagerfeuer siehst. Dort untersuche die Grabsteine.", "Go to the north where you can find four campfires. Examine the tombstones there."):execute()
    handler.createplayeritem.createPlayerItem(PLAYER, 336, 333, 1):execute()
end

function ADDITIONALCONDITIONS(PLAYER)
return true
end