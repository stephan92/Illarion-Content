require("handler.sendmessagetoplayer")
require("questsystem.base")
module("questsystem.information_runewick_1.trigger23", package.seeall)

local QUEST_NUMBER = 621
local PRECONDITION_QUESTSTATE = 100
local POSTCONDITION_QUESTSTATE = 91

local NPC_TRIGGER_DE = "30|[Dd]rei�ig"
local NPC_TRIGGER_EN = "30|[Tt]hirty"
local NPC_REPLY_DE = "Gut, um mehr �ber die Geschichte Runewicks zu erfahren, empfiehlt sich unser Geschichtsbuch. Und dieses soll nun auch gelesen werden."
local NPC_REPLY_EN = "Good, if you want to know more about the history of Runewick look for the histroy book. So, go and find it."

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
    handler.sendmessagetoplayer.sendMessageToPlayer(PLAYER, "Such nach dem Geschichtsbuch von Runewick in einem der B�cherregalen.", "Find the history book of Runewick in one of the bookshelves."):execute()
end

function ADDITIONALCONDITIONS(PLAYER)
return true
end