--[[
Illarion Server

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
details.

You should have received a copy of the GNU Affero General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>.
]]
local monstermagic = require("monster.base.monstermagic")
local base = require("monster.base.base")
local drop = require("monster.base.drop")
local lookat = require("monster.base.lookat")
local quests = require("monster.base.quests")
local messages = require("base.messages")
local kills = require("monster.base.kills")
local arena = require("base.arena")
local M = {}
local init = nil



function ini(Monster)

init=true;
quests.iniQuests();
killer={}; --A list that keeps track of who attacked the monster last

--Random Messages
msgs = messages.Messages();
msgs:addMessage("#me gackert.", "#me cackles.");

end

function M.enemyNear(Monster,Enemy)

    if init==nil then
        ini(Monster);
    end

    if math.random(1,10) == 1 then
        drop.MonsterRandomTalk(Monster,msgs); --a random message is spoken once in a while
    end

    return false
end

function M.enemyOnSight(Monster,Enemy)

    if init==nil then
        ini(Monster);
    end

	monstermagic.regeneration(Monster); --if an enemy is around, the monster regenerates slowly
    drop.MonsterRandomTalk(Monster,msgs); --a random message is spoken once in a while

	if base.isMonsterArcherInRange(Monster, Enemy) then
		return true
	end

	if base.isMonsterInRange(Monster, Enemy) then
        return true;
    else
        return false
    end
end

function M.onAttacked(Monster,Enemy)

    if init==nil then
        ini(Monster);
    end
    kills.setLastAttacker(Monster,Enemy)
    killer[Monster.id]=Enemy.id; --Keeps track who attacked the monster last
end

function M.onCasted(Monster,Enemy)

    if init==nil then
        ini(Monster);
    end
    kills.setLastAttacker(Monster,Enemy)
    killer[Monster.id]=Enemy.id; --Keeps track who attacked the monster last
end

function M.onDeath(Monster)

    if arena.isArenaMonster(Monster) then
        return
    end


    if killer and killer[Monster.id] ~= nil then

        murderer=getCharForId(killer[Monster.id]);

        if murderer then --Checking for quests

            quests.checkQuest(murderer,Monster);
            killer[Monster.id]=nil;
            murderer=nil;

        end
    end

    drop.ClearDropping();
    local MonID=Monster:getMonsterType();

if (MonID==921) then --Sewerrat, Level: 2, Armourtype: cloth, Weapontype: slashing

        --Category 1: Armor

        local done=drop.AddDropItem(697,1,20,(100*math.random(1,2)+math.random(11,22)),0,1); --fur boots
        if not done then done=drop.AddDropItem(19,1,10,(100*math.random(1,2)+math.random(11,22)),0,1); end --metal shield
        if not done then done=drop.AddDropItem(366,1,1,(100*math.random(1,2)+math.random(11,22)),0,1); end --fur trousers
        if not done then done=drop.AddDropItem(364,1,1,(100*math.random(1,2)+math.random(11,22)),0,1); end --light hunting armor
        if not done then done=drop.AddDropItem(365,1,1,(100*math.random(1,2)+math.random(11,22)),0,1); end --half leather armor

        --Category 2: Special Loot

        local done=drop.AddDropItem(333,1,20,(100*math.random(1,2)+math.random(11,22)),0,2); --horn
        if not done then done=drop.AddDropItem(92,1,10,(100*math.random(1,2)+math.random(11,22)),0,2); end --oil lamp
        if not done then done=drop.AddDropItem(306,1,1,(100*math.random(1,2)+math.random(11,22)),0,2); end --ham
        if not done then done=drop.AddDropItem(97,1,1,(100*math.random(1,2)+math.random(11,22)),0,2); end --bag
        if not done then done=drop.AddDropItem(224,1,1,(100*math.random(1,2)+math.random(11,22)),0,2); end --golden goblet

        --Category 3: Weapons

        local done=drop.AddDropItem(78,1,20,(100*math.random(1,2)+math.random(11,22)),0,3); --short sword
        if not done then done=drop.AddDropItem(445,1,10,(100*math.random(1,2)+math.random(11,22)),0,3); end --wooden sword
        if not done then done=drop.AddDropItem(2757,1,1,(100*math.random(1,2)+math.random(11,22)),0,3); end --scimitar
        if not done then done=drop.AddDropItem(25,1,1,(100*math.random(1,2)+math.random(11,22)),0,3); end --sabre
        if not done then done=drop.AddDropItem(2701,1,1,(100*math.random(1,2)+math.random(11,22)),0,3); end --longsword

        --Category 4: Perma Loot
        drop.AddDropItem(3076,math.random(10,30),100,773,0,4); --copper coins


    elseif (MonID==922) then --Giant Sewerrat, Level: 3, Armourtype: cloth, Weapontype: concussion

        --Category 1: Armor

        local done=drop.AddDropItem(257,1,20,(100*math.random(2,3)+math.random(22,33)),0,1); --leather shoes
        if not done then done=drop.AddDropItem(253,1,10,(100*math.random(2,3)+math.random(22,33)),0,1); end --leather legs
        if not done then done=drop.AddDropItem(251,1,1,(100*math.random(2,3)+math.random(22,33)),0,1); end --light hunting armor
        if not done then done=drop.AddDropItem(252,1,1,(100*math.random(2,3)+math.random(22,33)),0,1); end --full leatherarmor
        if not done then done=drop.AddDropItem(817,1,1,(100*math.random(2,3)+math.random(22,33)),0,1); end --green tunic

        --Category 2: Special Loot

        local done=drop.AddDropItem(197,1,20,(100*math.random(2,3)+math.random(22,33)),0,2); --amethyst
        if not done then done=drop.AddDropItem(283,1,10,(100*math.random(2,3)+math.random(22,33)),0,2); end --obsidian
        if not done then done=drop.AddDropItem(2183,1,1,(100*math.random(2,3)+math.random(22,33)),0,2); end --clay mug
        if not done then done=drop.AddDropItem(332,1,1,(100*math.random(2,3)+math.random(22,33)),0,2); end --harp
        if not done then done=drop.AddDropItem(224,1,1,(100*math.random(2,3)+math.random(22,33)),0,2); end --golden goblet

        --Category 3: Weapons

        local done=drop.AddDropItem(230,1,20,(100*math.random(2,3)+math.random(22,33)),0,3); --mace
        if not done then done=drop.AddDropItem(2664,1,10,(100*math.random(2,3)+math.random(22,33)),0,3); end --club
        if not done then done=drop.AddDropItem(2737,1,1,(100*math.random(2,3)+math.random(22,33)),0,3); end --morning star
        if not done then done=drop.AddDropItem(2786,1,1,(100*math.random(2,3)+math.random(22,33)),0,3); end --branch
        if not done then done=drop.AddDropItem(56,1,1,(100*math.random(2,3)+math.random(22,33)),0,3); end --bough

        --Category 4: Perma Loot
        drop.AddDropItem(3076,math.random(20,60),100,773,0,4); --copper coins

    end
    drop.Dropping(Monster);
end

return M

