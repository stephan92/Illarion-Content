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
local kills = require("monster.base.kills")
local arena = require("base.arena")
local messages = require("base.messages")
local M = {}
local init = nil


--To do: Random Messages

function ini(Monster)

init=true;
    quests.iniQuests();
    killer={}; --A list that keeps track of who attacked the monster last

    --Random Messages

    msgs = messages.Messages();
    msgs:addMessage("#me starrt aus vielen Augen.", "#me stares with multiple eyes.");
    msgs:addMessage("#me guckt.", "#me goggles.");
    msgs:addMessage("#me schwebt einen Meter �ber dem Boden.", "#me floats three feet over the ground.");
    msgs:addMessage("Die Sch�nheit liegt in meinen Augen!", "Beauty is in my eyes!");
    msgs:addMessage("Ich habe das gesehen!", "I saw that!");
    msgs:addMessage("#me ist eine beeindruckende Sph�re, die wie durch Magie �ber dem Boden schwebt.", "#me is an impressive sphere that floats over the ground by magic.");
    msgs:addMessage("#me zwinkert mit einem Auge.", "#me blinks with one of its eyes.");
    msgs:addMessage("Ich geh�re keinem Zauberer.", "I am not the property of any wizard.");
    msgs:addMessage("Da werd ich mal ein Auge zudr�cken.","I'll turn a blind eye to you.");
    msgs:addMessage("Gehorche.","Obey me.");
	msgs:addMessage("#me schwebt umher.","#me floats.");

end

function M.enemyNear(Monster,Enemy)

    if init==nil then
        ini(Monster);
    end

    if math.random(1,10) == 1 then
        drop.MonsterRandomTalk(Monster,msgs); --a random message is spoken once in a while
    end

	local MonID=Monster:getMonsterType();
    if (MonID==143) then
        return ( monstermagic.CastMonster(Monster, {611, 1031, 1051}) );
    else
        return false;
	end

end

function M.enemyOnSight(Monster,Enemy)
    if init==nil then
        ini(Monster);
        firstWP={};
    end

	monstermagic.regeneration(Monster); --if an enemy is around, the monster regenerates slowly
	drop.MonsterRandomTalk(Monster,msgs); --a random message is spoken once in a while

	local MonID=Monster:getMonsterType();

	if base.isMonsterArcherInRange(Monster, Enemy) then
		return true
	end

	if base.isMonsterInRange(Monster, Enemy) then
        return true;
    elseif (MonID==143) then
        return ( monstermagic.CastMonster(Monster, {611, 1031, 1051}) );
    else
        return false;
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

    if (MonID==141) then --Ghost Eye, Level: 4, Armourtype: light, Weapontype: concussion

        --Category 1: Raw gems

        local done=drop.AddDropItem(257,1,20,(100*math.random(3,4)+math.random(33,44)),0,1); --raw topaz
        if not done then done=drop.AddDropItem(251,1,10,(100*math.random(3,4)+math.random(33,44)),0,1); end --raw amethyst
        if not done then done=drop.AddDropItem(252,1,1,(100*math.random(3,4)+math.random(33,44)),0,1); end --raw obsidian
        if not done then done=drop.AddDropItem(256,1,1,(100*math.random(3,4)+math.random(33,44)),0,1); end --raw emerald
        if not done then done=drop.AddDropItem(254,1,1,(100*math.random(3,4)+math.random(33,44)),0,1); end --raw diamond

        --Category 2: Gems

        local done=drop.AddDropItem(284,1,20,(100*math.random(3,4)+math.random(33,44)),0,2); --sapphire
        if not done then done=drop.AddDropItem(198,1,10,(100*math.random(3,4)+math.random(33,44)),0,2); end --topaz
        if not done then done=drop.AddDropItem(285,1,1,(100*math.random(3,4)+math.random(33,44)),0,2); end --diamond
        if not done then done=drop.AddDropItem(197,1,1,(100*math.random(3,4)+math.random(33,44)),0,2); end --amethyst
        if not done then done=drop.AddDropItem(45,1,1,(100*math.random(3,4)+math.random(33,44)),0,2); end --emerald

        --Category 3: Rings

        local done=drop.AddDropItem(281,1,20,(100*math.random(3,4)+math.random(33,44)),0,3); --emerald ring
        if not done then done=drop.AddDropItem(280,1,10,(100*math.random(3,4)+math.random(33,44)),0,3); end --diamond ring
        if not done then done=drop.AddDropItem(277,1,1,(100*math.random(3,4)+math.random(33,44)),0,3); end --amethyst ring
        if not done then done=drop.AddDropItem(68,1,1,(100*math.random(3,4)+math.random(33,44)),0,3); end --ruby ring
        if not done then done=drop.AddDropItem(282,1,1,(100*math.random(3,4)+math.random(33,44)),0,3); end --topaz ring

        --Category 4: Perma Loot
        drop.AddDropItem(3076,math.random(30,90),100,333,0,4); --copper coins


    elseif (MonID==142) then --Unholy Ghost Eye', Level: 5, Armourtype: light, Weapontype: puncture

        --Category 1: Raw gems

        local done=drop.AddDropItem(256,1,20,(100*math.random(4,5)+math.random(44,55)),0,1); --raw emerald
        if not done then done=drop.AddDropItem(255,1,10,(100*math.random(4,5)+math.random(44,55)),0,1); end --raw ruby
        if not done then done=drop.AddDropItem(257,1,1,(100*math.random(4,5)+math.random(44,55)),0,1); end --raw topaz
        if not done then done=drop.AddDropItem(254,1,1,(100*math.random(4,5)+math.random(44,55)),0,1); end --raw diamond
        if not done then done=drop.AddDropItem(252,1,1,(100*math.random(4,5)+math.random(44,55)),0,1); end --raw obsidian

        --Category 2: Gems

        local done=drop.AddDropItem(283,1,20,(100*math.random(4,5)+math.random(44,55)),0,2); --obsidian
        if not done then done=drop.AddDropItem(45,1,10,(100*math.random(4,5)+math.random(44,55)),0,2); end --emerald
        if not done then done=drop.AddDropItem(283,1,1,(100*math.random(4,5)+math.random(44,55)),0,2); end --obsidian
        if not done then done=drop.AddDropItem(197,1,1,(100*math.random(4,5)+math.random(44,55)),0,2); end --amethyst
        if not done then done=drop.AddDropItem(285,1,1,(100*math.random(4,5)+math.random(44,55)),0,2); end --diamond

        --Category 3: Rings

        local done=drop.AddDropItem(282,1,20,(100*math.random(4,5)+math.random(44,55)),0,3); --topaz ring
        if not done then done=drop.AddDropItem(279,1,10,(100*math.random(4,5)+math.random(44,55)),0,3); end --sapphire ring
        if not done then done=drop.AddDropItem(281,1,1,(100*math.random(4,5)+math.random(44,55)),0,3); end --emerald ring
        if not done then done=drop.AddDropItem(277,1,1,(100*math.random(4,5)+math.random(44,55)),0,3); end --amethyst ring
        if not done then done=drop.AddDropItem(68,1,1,(100*math.random(4,5)+math.random(44,55)),0,3); end --ruby ring

        --Category 4: Perma Loot
        drop.AddDropItem(3076,math.random(60,180),100,333,0,4); --copper coins


        elseif (MonID==143) then --Horrible Ghost Eye, Level: 6, Armourtype: heavy, Weapontype: slashing

        --Category 1: Raw gems

        local done=drop.AddDropItem(253,1,20,(100*math.random(6,7)+math.random(66,77)),0,1); --raw sapphire
        if not done then done=drop.AddDropItem(256,1,10,(100*math.random(6,7)+math.random(66,77)),0,1); end --raw emerald
        if not done then done=drop.AddDropItem(255,1,1,(100*math.random(6,7)+math.random(66,77)),0,1); end --raw ruby
        if not done then done=drop.AddDropItem(257,1,1,(100*math.random(6,7)+math.random(66,77)),0,1); end --raw topaz
        if not done then done=drop.AddDropItem(252,1,1,(100*math.random(6,7)+math.random(66,77)),0,1); end --raw obsidian

        --Category 2: Gems

        local done=drop.AddDropItem(45,1,20,(100*math.random(6,7)+math.random(66,77)),0,2); --emerald
        if not done then done=drop.AddDropItem(197,1,10,(100*math.random(6,7)+math.random(66,77)),0,2); end --amethyst
        if not done then done=drop.AddDropItem(46,1,1,(100*math.random(6,7)+math.random(66,77)),0,2); end --ruby
        if not done then done=drop.AddDropItem(198,1,1,(100*math.random(6,7)+math.random(66,77)),0,2); end --topaz
        if not done then done=drop.AddDropItem(283,1,1,(100*math.random(6,7)+math.random(66,77)),0,2); end --obsidian

        --Category 3: Rings

        local done=drop.AddDropItem(280,1,20,(100*math.random(6,7)+math.random(66,77)),0,3); --diamond ring
        if not done then done=drop.AddDropItem(281,1,10,(100*math.random(6,7)+math.random(66,77)),0,3); end --emerald ring
        if not done then done=drop.AddDropItem(279,1,1,(100*math.random(6,7)+math.random(66,77)),0,3); end --obsidian ring
        if not done then done=drop.AddDropItem(282,1,1,(100*math.random(6,7)+math.random(66,77)),0,3); end --topaz ring
        if not done then done=drop.AddDropItem(277,1,1,(100*math.random(6,7)+math.random(66,77)),0,3); end --amethyst ring

        --Category 4: Perma Loot
        drop.AddDropItem(3077,math.random(2,5),100,333,0,4); --silver coins

        -- Drops
    elseif (MonID==144) then
        --Drops
    elseif (MonID==145) then
        --Drops
    elseif (MonID==146) then
        --Drops
    else
        --Drops
    end
    drop.Dropping(Monster);
end

return M

