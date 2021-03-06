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
local common = require("base.common")
local character = require("base.character")
local chr_reg = require("lte.chr_reg")

local M = {}

-- This function regenerates monsters slowly

function M.regeneration( Monster )

    if ( Monster:increaseAttrib("hitpoints", 0) < 10000) and (math.random(1, 3) == 1) then -- Once each 3rd second in average
        local con = Monster:increaseAttrib("constitution", 0);
        local healAmount = 2 * con; --A very strong Monster with 50 CON would regenerate 20% health/minute. A weak monster with 10 CON would regenerate 4% health/minute
        Monster:increaseAttrib("hitpoints", healAmount);
    end

end


-- Spell resistance calculation might need simplification

function M.SpellResistence( Char )
    local CWil   = Char:increaseAttrib("willpower",0);
    local CEss   = Char:increaseAttrib("essence",0);
    local CSkill = Char:getSkill(Character.magicResistance) ;
    CSkill = common.Limit( CSkill, 0, M.MaximalMagicResistance( Char ) );

    local ResTry = common.Limit(CSkill * ( ( CEss*3 + CWil*2 ) / 63 ), 0, 100 );

    return common.Limit( math.floor( ResTry * math.random(8,12)/10 ), 0, 100 );
end

function M.MaximalMagicResistance( Char )
    local maxMagicResist = 1.4 * ( Char:increaseAttrib("intelligence",0) + ( Char:increaseAttrib("willpower",0) * 1.75 ) + ( Char:increaseAttrib("essence",0) * 2 ) ) + 5;
    return common.Limit( maxMagicResist, 0, 100 );
end


-- This function teleports the monster away  few fields

function M.SuddenWarp(Monster, Enemy, rndTry)
    if rndTry == nil then
        rndTry = 30; -- Once every 30 seconds in average
    end

    if (math.random(1, rndTry) ~= 1) then
        return false;
    end

    local XOffset = math.random(-5, 5);
    local YOffset = math.random(-5, 5);
    if (math.sqrt((XOffset * XOffset) + (YOffset * YOffset)) < 2) then
        XOffset = 2;
    end
    world:gfx(41, Monster.pos);
    Monster:warp(position(Enemy.pos.x + XOffset, Enemy.pos.y + YOffset, Enemy.pos.z));
    world:gfx(41, Monster.pos);
    Monster.movepoints = Monster.movepoints - 20;

    return true;
end


-- This function heals a random monster

function M.CastHealing(Monster, HealAmount, rndTry)
    if rndTry == nil then
        rndTry = 10; -- Once every 10 seconds in average
    end

    if (math.random(1, rndTry) ~= 1) then
        return false;
    end

    -- Look for my friends
    local other_monsters = world:getMonstersInRangeOf(Monster.pos, 8);
    if #other_monsters == 0 then
        return false;
    end

    -- Scan Monsters and select wounded
    local monsters_in_need = {};
    for i, monster in pairs(other_monsters) do
        if (monster:increaseAttrib("hitpoints", 0) < 10000) then
            table.insert(monsters_in_need, i);
        end
    end

    if #monsters_in_need == 0 then
        return false;
    end

    -- Select monster to help
    local selected_monster = math.random(1, #monsters_in_need);

    other_monsters[selected_monster]:increaseAttrib("hitpoints", math.random(HealAmount[1], HealAmount[2]));

    world:gfx(16, other_monsters[selected_monster].pos );
    world:makeSound(13, other_monsters[selected_monster].pos );

    other_monsters[selected_monster].movepoints = other_monsters[selected_monster].movepoints - 40;
    Monster.movepoints = Monster.movepoints - 20;

    return true;
end


-- This function drains movepoints of a monster's enemy
-- XXX: CastingTry and Spell Resistence is a mess

function M.CastParalyze(Monster, Enemy, CastingTry, rndTry)
    if rndTry == nil then
        rndTry = 10; -- Once every 10 seconds in average
    end

    if (math.random(1, rndTry) ~= 1) then
        return false;
    end

    if (Monster.pos.z ~= Enemy.pos.z) then
        return false;
    end

    local CastTry = math.random(CastingTry[1],CastingTry[2]) - M.SpellResistence( Enemy );
    CastTry = ( CastTry - CastingTry[1] ) / ( CastingTry[2] - CastingTry[1] ) * 100;

    local Damage = common.ScaleUnlimited(30, 60, CastTry);
    if Damage > 0 then
        Enemy.movepoints = Enemy.movepoints - Damage;
        world:gfx(6, Enemy.pos);
    else
        world:gfx(12, Enemy.pos);
    end
    world:makeSound(1, Enemy.pos);

    Monster.movepoints = Monster.movepoints - 20;

    return true;
end


-- Spawn a new monster

function M.CastMonster(Monster, monsters, rndTry)
    if rndTry == nil then
        rndTry = 30; -- Once every 30 seconds in average
    end

    if (math.random(1, rndTry) ~= 1) then
        return false;
    end

    local selectedMonsterIndex = math.random(1, #monsters);
    local selectedMonsterId = monsters[selectedMonsterIndex];

    local i = 0;

    while i < 20 do
        local XPos = math.random(-2, 2);
        local YPos = math.random(-2, 2);

        if XPos == 0 and YPos == 0 then
            YPos = -1;
        end

        local SpawnPos = position(Monster.pos.x + XPos, Monster.pos.y + YPos, Monster.pos.z);

        if world:isCharacterOnField(SpawnPos) then
            return false;
        end

        if world:getField(SpawnPos) then
            world:createMonster(selectedMonsterId, SpawnPos, -15);
            world:gfx(41, SpawnPos);
            Monster.movepoints = Monster.movepoints - 40;
            common.TalkNLS(Monster, Character.say,
                "#me murmelt eine mystische Formel.",
                "#me mumbles a mystical formula.");
            return true;
        else
            i = i + 1;
        end
    end

    return false;
end


-- A area damage spell
-- XXX: CastingTry and Spell Resistence is a mess

function M.CastLargeAreaMagic(monster, DamageRange, CastingTry, rndTry)
    if rndTry == nil then
        rndTry = 30; -- Once every 30 seconds in average
    end

    if (loadingMonsters == nil) then
        loadingMonsters = {};
    end;

    LoadupRounds = 3;
    if (loadingMonsters[monster.id] ~= nil) then
        if ( loadingMonsters[monster.id] ~= LoadupRounds ) then
            loadingMonsters[monster.id] = loadingMonsters[monster.id] + 1;

            world:gfx(37, monster.pos );
            monster.movepoints = monster.movepoints - 60;
            return true;
        end
    elseif (math.random(1, rndTry) == 1) then
        loadingMonsters[monster.id] = 1;

        if ( LoadupRounds > 0 ) then
            world:gfx(37, monster.pos );
            monster.movepoints = monster.movepoints - 60;
            return true;
        end
    else
        return false;
    end

    loadingMonsters[monster.id] = nil;

    local targets = world:getPlayersInRangeOf( monster.pos, 8 );
    local CastTry = 0;
    local Damage = 0;
    for i,target in pairs(targets) do
        local CastTry = math.random(CastingTry[1],CastingTry[2]) - M.SpellResistence( target );
        CastTry = ( CastTry - CastingTry[1] ) / ( CastingTry[2] - CastingTry[1] ) * 100;
        local Damage = common.ScaleUnlimited( DamageRange[1], DamageRange[2], CastTry );
        if Damage > 0 then
            M.DealMagicDamage(target, Damage);
            world:gfx(36, target.pos);
        else
            world:gfx(12, target.pos);
        end
        world:makeSound(5, target.pos);
    end
    monster.movepoints = monster.movepoints - 60;
    return true;
end


-- A simple fireball spell

function M.CastFireball(Monster, Enemy, DamageRange, CastingTry, rndTry)
    if rndTry == nil then
        rndTry = 30; -- Once every 30 seconds in average
    end

    if (math.random(1, rndTry) ~= 1) then
        return false;
    end

    local blockList = world:LoS(Monster.pos, Enemy.pos)
    local next = next -- make next-iterator local
    if (next(blockList) ~= nil) then -- see if there is a "next" (first) object in blockList!
        return false; -- something blocks
    end

    common.CreateLine(Monster.pos, Enemy.pos, function(targetPos)
        if world:isCharacterOnField( targetPos ) then
            local Enemy = world:getCharacterOnField( targetPos );
            local CastTry = math.random(CastingTry[1],CastingTry[2]) - M.SpellResistence( Enemy );
            CastTry = ( CastTry - CastingTry[1] ) / ( CastingTry[2] - CastingTry[1] ) * 100;
            local Damage = common.ScaleUnlimited( DamageRange[1], DamageRange[2], CastTry );
            if Damage > 0 then
                M.DealMagicDamage(Enemy, Damage);
                world:gfx(44, targetPos);
            else
                world:gfx(12, targetPos);
            end
            world:makeSound(5, targetPos);
            return false;
        end;
        world:gfx(1, targetPos);
        return true;
    end );
    common.TalkNLS( Monster, Character.say,
        "#me murmelt eine mystische Formel.",
        "#me mumbles a mystical formula.");

    Monster.movepoints = Monster.movepoints - 40;
    return true;
end

-- A flame field on the ground

function M.CastFlamefield(Monster, Enemy, QualityRange, rndTry)
    if rndTry == nil then
        rndTry = 30; -- Once every 30 seconds in average
    end

    if (math.random(1, rndTry) ~= 1) then
        return false;
    end

    local blockList = world:LoS(Monster.pos, Enemy.pos)
    local next = next -- make next-iterator local
    if (next(blockList) ~= nil) then -- see if there is a "next" (first) object in blockList!
        return false; -- something blocks
    end

    common.CreateLine(Monster.pos, Enemy.pos, function(targetPos)
        if world:isCharacterOnField( targetPos ) then
            if world:isItemOnField( targetPos ) then
                local foundItem = world:getItemOnField( targetPos );
                if ( foundItem.id == 359 ) then
                    foundItem.quality = math.min( QualityRange[2], foundItem.quality + QualityRange[1] );
                    return false;
                end
            end
            world:createItemFromId(359, 1, targetPos, true, math.random(QualityRange[1], QualityRange[2]), nil);
            world:makeSound(5, targetPos);
            return false;
        end;
        world:gfx(1, targetPos);
        return true;
    end );
    common.TalkNLS( Monster, Character.say,
        "#me murmelt eine mystische Formel.",
        "#me mumbles a mystical formula.");

    Monster.movepoints = Monster.movepoints - 40;
    return true;
end

-- Fire breathing for dragons
-- Note: depending on graphicItem it might lso spit poison or ice, or whatever

function M.FireBreath(Monster, Enemy, graphicItem)
    if (firstBreath==nil) then
        NearBreathShape={};
        NearBreathShape[1]={9,9,9,9,9};
        NearBreathShape[2]={0,9,9,9,0};
        NearBreathShape[3]={0,9,9,9,0};
        NearBreathShape[4]={0,0,9,0,0};
        NearBreathShape[5]={0,0,9,0,0};
        firstBreath=true;
    end

    local BreathTry=math.random(1,66);
    if (BreathTry==1) and (Monster.pos.z==Enemy.pos.z) then
        Monster.fightpoints=Monster.fightpoints-40;
        if (Monster:distanceMetric(Enemy)<=4) then
            Looking=Monster:getFaceTo()
            if (Looking==0) then
                BreathShape=NearBreathShape;
            elseif (Looking==2) then
                BreathShape=M.ShapeDrehen(NearBreathShape);
            elseif (Looking==4) then
                BreathShape=M.ShapeDrehen(M.ShapeDrehen(NearBreathShape));
            elseif (Looking==6) then
                BreathShape=M.ShapeDrehen(M.ShapeDrehen(M.ShapeDrehen(NearBreathShape)));
            end
            for i=1,5 do
                for k=1,5 do
                    if (Looking==0) then
                        BreathPos=position(Monster.pos.x-3+k,Monster.pos.y-7+i,Monster.pos.z);
                    elseif (Looking==2) then
                        BreathPos=position(Monster.pos.x+k,Monster.pos.y-3+i,Monster.pos.z);
                    elseif (Looking==4) then
                        BreathPos=position(Monster.pos.x-3+k,Monster.pos.y+i,Monster.pos.z);
                    elseif (Looking==6) then
                        BreathPos=position(Monster.pos.x-7+k,Monster.pos.y-3+i,Monster.pos.z);
                    end
                    if (BreathShape[i][k]~=0) then
                        world:gfx(BreathShape[i][k],BreathPos);
                        if (math.random(1,5)==1) then
                            world:createItemFromId(graphicItem,1,BreathPos,true,math.random(200,600),nil);
                            world:makeSound(5,BreathPos);
                        end
                        if world:isCharacterOnField(BreathPos) then
                            local HitCharacter=world:getCharacterOnField(BreathPos);
                            HitCharacter:increaseAttrib("hitpoints",-2000)
                        end
                    end
                end
            end
        else
            return false
        end
    end
    growltry=math.random(1,8);
    if (growltry==1) then
        world:makeSound(26,Monster.pos);
    end
    return true
end

function M.ShapeDrehen(Shape)
    retShape={};
    for i=1,5 do
        retShape[i]={Shape[5][i],Shape[4][i],Shape[3][i],Shape[2][i],Shape[1][i]};
    end
    return retShape
end


-- Helper function to handle the Brink of Death

function M.DealMagicDamage(Target, Damage)
    if character.IsPlayer(Target)
        and character.WouldDie(Target, Damage + 1)
        and not character.AtBrinkOfDeath(Target) then
        -- Character would die.
        character.ToBrinkOfDeath(Target);
        common.TalkNLS(Target, Character.say,
            "#me geht zu Boden.",
            "#me falls to the ground.");

        if not Target:isAdmin() then --Admins don't want to get paralysed!
            common.ParalyseCharacter(Target, 2, false, true);
            TimeFactor = 1; -- See lte.chr_reg
            chr_reg.stallRegeneration(Target, 60/TimeFactor); -- Stall regeneration for one minute. Attention! If you change TimeFactor in lte.chr_reg to another value but 1, you have to divide this "60" by that factor
        end
    else
        Target:increaseAttrib("hitpoints", -Damage);
    end
end

return M

