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


function M.onSpawn(theOrc)

	local mySex = math.random(0,1);

    local var=20; -- variation of color, +/- var
    local baseR=50;  -- baseRed
	local baseG=120;  -- baseGreen
	local baseB=30;  -- baseBlue
    local red = math.min(255, baseR + math.random(-var, var));
    local green = math.min(255, baseG + math.random(-var, var));
    local blue = math.min(255, baseB + math.random(-var, var));
    local myHair = {};
    myHair[0] = {1,2,3,4,5};    -- list of possible hair IDs
    myHair[1] = {1,4,7,8};
    local hairBlonde = {240,230,90} -- Blonde hair Red,Green,Blue
	local hairPurple = {128,0,128} -- Purple hair Red,Green,Blue
	local hairRed = {165,10,10} -- Red hair Red,Green,Blue
	local hairBrunette = {128,64,0} -- Brunette hair Red,Green,Blue
	local hairColors = {hairBlonde, hairPurple, hairRed, hairBrunette}
	local myHairColor = hairColors[math.random(#hairColors)]
	theOrc:setAttrib("sex",mySex);
    theOrc:setSkinColor(red,green,blue);
    theOrc:setHair( myHair[mySex][math.random(#myHair[mySex])] );
    theOrc:setHairColor(myHairColor[1], myHairColor[2], myHairColor[3] );
 end
 
function ini(Monster)

init=true;
quests.iniQuests();
killer={}; --A list that keeps track of who attacked the monster last

--Random Messages

msgs = messages.Messages();
msgs:addMessage("#me br�llt laut und kraftvoll.", "#me roars loudly and powerfully.");
msgs:addMessage("#me fletscht gr�ssliche gelbe Z�hne.", "#me bares ugly yellow teeth.");
msgs:addMessage("#me grunzt b�sartig.", "#me grunts angrily.");
msgs:addMessage("#me knurrt leise und bedrohlich.", "#me snarls quietly and threateningly.");
msgs:addMessage("#me lacht heiser.", "#me laughs hoarsely.");
msgs:addMessage("#me spuckt auf den Boden, ein bo�haftes Grinsen auf dem Gesicht.", "#me spits at the ground, an evil grin stands in the face.");
msgs:addMessage("Bluuuuut!", "Bloooood!");
msgs:addMessage("D' Vatherr mit mirr ist!", "Da Fadha beh whib me!");
msgs:addMessage("F�r d'n Vatherr von alle Orks!", "For da Fadha op all orcis!");
msgs:addMessage("Mirr zermatsch! Hurr! H�ssliche Fresse!", "Me smash! Hurr! Ugly fais!");
msgs:addMessage("Renn wie Feigling, renn!", "Run coward, run!");
msgs:addMessage("Starr mirr nischt so an!", "Nub stare at me like dat!");
msgs:addMessage("Mir w�tend. Mir dir nun auseinandernehmen wie Spinne! Mir dir zertreten wie Made!", "Me angry! Me smash yoos like spider. Mes stomp yoos like maggot!");
msgs:addMessage("#me schl�gt sich an die Brust und r�hrt heiser: 'In den Kampf, ein Ork dr�ckt sich nicht!'", "#me slams his fist on his chest and roars: 'On dem! Orcis nub retreat!'");
msgs:addMessage("#me ist gr�n.", "#me is green.");

end

function M.enemyNear(Monster,Enemy)

    local MonID=Monster:getMonsterType();
    if init==nil then
        ini(Monster);
    end

    if math.random(1,10) == 1 then
        drop.MonsterRandomTalk(Monster,msgs); --a random message is spoken once in a while
    end

    if (MonID==45) then
        return ( monstermagic.CastHealing( Monster, {1000, 2000}) );
    else
        return false
    end
end

function M.enemyOnSight(Monster,Enemy)

	local MonID=Monster:getMonsterType();
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
    elseif (MonID==45) then
        return ( monstermagic.CastFireball(Monster, Enemy, {1000, 2000}, {50, 60}) or monstermagic.CastHealing( Monster, {1000,2000}) );
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
        if (MonID==41) then --Orc, Level: 5, Armourtype: medium, Weapontype: concussion

        --Category 1: Armor

        local done=drop.AddDropItem(2194,1,20,(100*math.random(4,5)+math.random(44,55)),0,1); --short hardwood greaves
        if not done then done=drop.AddDropItem(2287,1,10,(100*math.random(4,5)+math.random(44,55)),0,1); end --albarian soldier's helmet
        if not done then done=drop.AddDropItem(2367,1,1,(100*math.random(4,5)+math.random(44,55)),0,1); end --albarian noble's armor
        if not done then done=drop.AddDropItem(2388,1,1,(100*math.random(4,5)+math.random(44,55)),0,1); end --red steel shield
        if not done then done=drop.AddDropItem(101,1,1,(100*math.random(4,5)+math.random(44,55)),0,1); end --chain shirt

        --Category 2: Special loot

        local done=drop.AddDropItem(3051,1,20,(100*math.random(4,5)+math.random(44,55)),0,2); --sausage
        if not done then done=drop.AddDropItem(97,1,10,(100*math.random(4,5)+math.random(44,55)),0,2); end --bag
        if not done then done=drop.AddDropItem(63,1,1,(100*math.random(4,5)+math.random(44,55)),0,2); end --entrails
        if not done then done=drop.AddDropItem(2738,1,1,(100*math.random(4,5)+math.random(44,55)),0,2); end --nails
        if not done then done=drop.AddDropItem(2760,1,1,(100*math.random(4,5)+math.random(44,55)),0,2); end --rope

        --Category 3: Weapon

        local done=drop.AddDropItem(2664,1,20,(100*math.random(4,5)+math.random(44,55)),0,3); --club
        if not done then done=drop.AddDropItem(231,1,10,(100*math.random(4,5)+math.random(44,55)),0,3); end --mace
        if not done then done=drop.AddDropItem(231,1,1,(100*math.random(4,5)+math.random(44,55)),0,3); end --morning star
        if not done then done=drop.AddDropItem(2737,1,1,(100*math.random(4,5)+math.random(44,55)),0,3); end --morning star
        if not done then done=drop.AddDropItem(226,1,1,(100*math.random(4,5)+math.random(44,55)),0,3); end --warhammer

        --Category 4: Perma Loot
        drop.AddDropItem(3076,math.random(60,180),100,333,0,4); --copper coins


    elseif (MonID==42) then --Orc Warrior, Level: 6, Armourtype: heavy, Weapontype: slashing

        --Category 1: Armor

        local done=drop.AddDropItem(19,1,20,(100*math.random(5,6)+math.random(55,66)),0,1); --metal shield
        if not done then done=drop.AddDropItem(2172,1,10,(100*math.random(5,6)+math.random(55,66)),0,1); end --steel greaves
        if not done then done=drop.AddDropItem(2364,1,1,(100*math.random(5,6)+math.random(55,66)),0,1); end --steel plate
        if not done then done=drop.AddDropItem(2363,1,1,(100*math.random(5,6)+math.random(55,66)),0,1); end --nightplate
        if not done then done=drop.AddDropItem(2357,1,1,(100*math.random(5,6)+math.random(55,66)),0,1); end --shadowplate

        --Category 2: Special loot

        local done=drop.AddDropItem(333,1,20,(100*math.random(5,6)+math.random(55,66)),0,2); --horn
        if not done then done=drop.AddDropItem(2940,1,10,(100*math.random(5,6)+math.random(55,66)),0,2); end --steak
        if not done then done=drop.AddDropItem(2697,1,1,(100*math.random(5,6)+math.random(55,66)),0,2); end --rasp
        if not done then done=drop.AddDropItem(2681,1,1,(100*math.random(5,6)+math.random(55,66)),0,2); end --red dye
        if not done then done=drop.AddDropItem(391,1,1,(100*math.random(5,6)+math.random(55,66)),0,2); end --torch

        --Category 3: Weapon

        local done=drop.AddDropItem(25,1,20,(100*math.random(5,6)+math.random(55,66)),0,3); --sabre
        if not done then done=drop.AddDropItem(2658,1,10,(100*math.random(5,6)+math.random(55,66)),0,3); end --broad sword
        if not done then done=drop.AddDropItem(2701,1,1,(100*math.random(5,6)+math.random(55,66)),0,3); end --longsword
        if not done then done=drop.AddDropItem(2757,1,1,(100*math.random(5,6)+math.random(55,66)),0,3); end --scimitar
        if not done then done=drop.AddDropItem(2642,1,1,(100*math.random(5,6)+math.random(55,66)),0,3); end --orc axe

        --Category 4: Perma Loot
        drop.AddDropItem(3077,math.random(2,5),100,333,0,4); --silver coins


    elseif (MonID==43) then --Orc Thief, Level: 4, Armourtype: light, Weapontype: puncture

        --Category 1: Armor

        local done=drop.AddDropItem(369,1,20,(100*math.random(3,4)+math.random(33,44)),0,1); --leather shoes
        if not done then done=drop.AddDropItem(367,1,10,(100*math.random(3,4)+math.random(33,44)),0,1); end --short leather legs
        if not done then done=drop.AddDropItem(365,1,1,(100*math.random(3,4)+math.random(33,44)),0,1); end --half leather armor
        if not done then done=drop.AddDropItem(365,1,1,(100*math.random(3,4)+math.random(33,44)),0,1); end --half leather armor
        if not done then done=drop.AddDropItem(365,1,1,(100*math.random(3,4)+math.random(33,44)),0,1); end --half leather armor

        --Category 2: Special loot

        local done=drop.AddDropItem(283,1,20,(100*math.random(3,4)+math.random(33,44)),0,2); --obsidian
        if not done then done=drop.AddDropItem(82,1,10,(100*math.random(3,4)+math.random(33,44)),0,2); end --obsidian amulet
        if not done then done=drop.AddDropItem(278,1,1,(100*math.random(3,4)+math.random(33,44)),0,2); end --obsidian ring
        if not done then done=drop.AddDropItem(252,1,1,(100*math.random(3,4)+math.random(33,44)),0,2); end --raw obsidian
        if not done then done=drop.AddDropItem(1858,1,1,(100*math.random(3,4)+math.random(33,44)),0,2); end --goblet

        --Category 3: Weapon

        local done=drop.AddDropItem(27,1,20,(100*math.random(3,4)+math.random(33,44)),0,3); --simple dagger
        if not done then done=drop.AddDropItem(189,1,10,(100*math.random(3,4)+math.random(33,44)),0,3); end --dagger
        if not done then done=drop.AddDropItem(2740,1,1,(100*math.random(3,4)+math.random(33,44)),0,3); end --red dagger
        if not done then done=drop.AddDropItem(190,1,1,(100*math.random(3,4)+math.random(33,44)),0,3); end --ornate dagger
        if not done then done=drop.AddDropItem(297,1,1,(100*math.random(3,4)+math.random(33,44)),0,3); end --golden dagger

        --Category 4: Perma Loot
        drop.AddDropItem(3076,math.random(30,90),100,333,0,4); --copper coins


    elseif (MonID==44) then --Orc Hunter, Level: 5, Armourtype: light, Weapontype: distance

        --Category 1: Armor

        local done=drop.AddDropItem(366,1,20,(100*math.random(4,5)+math.random(44,55)),0,1); --fur trousers
        if not done then done=drop.AddDropItem(48,1,10,(100*math.random(4,5)+math.random(44,55)),0,1); end --leather gloves
        if not done then done=drop.AddDropItem(365,1,1,(100*math.random(4,5)+math.random(44,55)),0,1); end --half leather armor
        if not done then done=drop.AddDropItem(365,1,1,(100*math.random(4,5)+math.random(44,55)),0,1); end --half leather armor
        if not done then done=drop.AddDropItem(2407,1,1,(100*math.random(4,5)+math.random(44,55)),0,1); end --light blue breastplate

        --Category 2: Special loot

        local done=drop.AddDropItem(552,1,20,(100*math.random(4,5)+math.random(44,55)),0,2); --deer meat
        if not done then done=drop.AddDropItem(307,1,10,(100*math.random(4,5)+math.random(44,55)),0,2); end --pork
        if not done then done=drop.AddDropItem(553,1,1,(100*math.random(4,5)+math.random(44,55)),0,2); end --rabbit meat
        if not done then done=drop.AddDropItem(2940,1,1,(100*math.random(4,5)+math.random(44,55)),0,2); end --steak
        if not done then done=drop.AddDropItem(2934,1,1,(100*math.random(4,5)+math.random(44,55)),0,2); end --lamb meat

        --Category 3: Weapon

        local done=drop.AddDropItem(1266,10,20,(100*math.random(4,5)+math.random(44,55)),0,3); --stones
        if not done then done=drop.AddDropItem(89,1,10,(100*math.random(4,5)+math.random(44,55)),0,3); end --sling
        if not done then done=drop.AddDropItem(65,1,1,(100*math.random(4,5)+math.random(44,55)),0,3); end --short bow
        if not done then done=drop.AddDropItem(2714,1,1,(100*math.random(4,5)+math.random(44,55)),0,3); end --hunting bow
        if not done then done=drop.AddDropItem(64,10,1,(100*math.random(4,5)+math.random(44,55)),0,3); end --arrows

        --Category 4: Perma Loot
        drop.AddDropItem(3076,math.random(60,180),100,333,0,4); --copper coins


    elseif (MonID==45) then --Orc Shaman, Level: 5, Armourtype: cloth, Weapontype: concussion

        --Category 1: Armor

        local done=drop.AddDropItem(460,1,20,(100*math.random(4,5)+math.random(44,55)),0,1); --yellow trouser
        if not done then done=drop.AddDropItem(458,1,10,(100*math.random(4,5)+math.random(44,55)),0,1); end --yellow shirt
        if not done then done=drop.AddDropItem(55,1,1,(100*math.random(4,5)+math.random(44,55)),0,1); end --green robe
        if not done then done=drop.AddDropItem(829,1,1,(100*math.random(4,5)+math.random(44,55)),0,1); end --yellow hat with feather
        if not done then done=drop.AddDropItem(818,1,1,(100*math.random(4,5)+math.random(44,55)),0,1); end --red tunic

        --Category 2: Special loot

        local done=drop.AddDropItem(63,1,20,(100*math.random(4,5)+math.random(44,55)),0,2); --entrails
        if not done then done=drop.AddDropItem(58,1,10,(100*math.random(4,5)+math.random(44,55)),0,2); end --mortar
        if not done then done=drop.AddDropItem(159,1,1,(100*math.random(4,5)+math.random(44,55)),0,2); end --toadstool
        if not done then done=drop.AddDropItem(158,1,1,(100*math.random(4,5)+math.random(44,55)),0,2); end --bulbsponge mushroom
        if not done then done=drop.AddDropItem(161,1,1,(100*math.random(4,5)+math.random(44,55)),0,2); end --herder's mushroom

        --Category 3: Weapon

        local done=drop.AddDropItem(39,1,20,(100*math.random(4,5)+math.random(44,55)),0,3); --skull staff
        if not done then done=drop.AddDropItem(40,1,10,(100*math.random(4,5)+math.random(44,55)),0,3); end --cleric's staff
        if not done then done=drop.AddDropItem(2664,1,1,(100*math.random(4,5)+math.random(44,55)),0,3); end --club
        if not done then done=drop.AddDropItem(57,1,1,(100*math.random(4,5)+math.random(44,55)),0,3); end --simple mage's staff
        if not done then done=drop.AddDropItem(76,1,1,(100*math.random(4,5)+math.random(44,55)),0,3); end --mage's staff

        --Category 4: Perma Loot
        drop.AddDropItem(3076,math.random(60,180),100,333,0,4); --copper coins

    elseif (MonID==46) then
        -- Drops
    elseif (MonID==47) then
        --Drops
    elseif (MonID==48) then
        --Drops
    elseif (MonID==49) then
        --Drops
    else
        --Drops
    end
    drop.Dropping(Monster);
end

return M

