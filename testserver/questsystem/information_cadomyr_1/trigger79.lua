require("handler.sendmessagetoplayer")
require("questsystem.base")
module("questsystem.information_cadomyr_1.trigger79", package.seeall)

local QUEST_NUMBER = 641
local PRECONDITION_QUESTSTATE = 109
local POSTCONDITION_QUESTSTATE = 331


function MoveToField( PLAYER )
    if ADDITIONALCONDITIONS(PLAYER)
    and questsystem.base.fulfilsPrecondition(PLAYER, QUEST_NUMBER, PRECONDITION_QUESTSTATE) then
    
        HANDLER(PLAYER)
    
        questsystem.base.setPostcondition(PLAYER, QUEST_NUMBER, POSTCONDITION_QUESTSTATE)
        return true
    end
    
    return false
end


function HANDLER(PLAYER)
    handler.sendmessagetoplayer.sendMessageToPlayer(PLAYER, "Vielleicht einer der drei S�rge da hinten? Gehe n�her und untersuche sie!", "Maybe one of these three coffins over there? Go closer and examine them!"):execute()
end

function ADDITIONALCONDITIONS(PLAYER)
return true
end