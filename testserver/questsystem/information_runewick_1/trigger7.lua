require("handler.sendmessagetoplayer")
require("handler.createplayeritem")
require("questsystem.base")
module("questsystem.information_runewick_1.trigger7", package.seeall)

local QUEST_NUMBER = 621
local PRECONDITION_QUESTSTATE = 34
local POSTCONDITION_QUESTSTATE = 41

local NPC_TRIGGER_DE = "[Hh]alle [Ee]lara"
local NPC_TRIGGER_EN = "[Hh]all [Ee]lara"
local NPC_REPLY_DE = "Sehr gut. Bevor wir mit dem praktischen Teil beginnen, noch ein paar mehr Fragen: Welchen dieser drei G�tter beten wir hier an? Irmorom, Malachin oder Elara?"
local NPC_REPLY_EN = "Very good. Bevor we start with the practical part, some more questions: To whom of these gods do we pray?  Irmorom, Malachin or Elara?"

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
    handler.createplayeritem.createPlayerItem(PLAYER, 3076, 333, 100):execute()
    handler.sendmessagetoplayer.sendMessageToPlayer(PLAYER, "Beantworte die gestellte Frage um mehr Geld und weitere Fragen zu erhalten. Hinweis: Frage sie nach 'Götter'.", "Answer the question to get more money and further questions. Hint: Ask about 'gods'."):execute()
end

function ADDITIONALCONDITIONS(PLAYER)
return true
end