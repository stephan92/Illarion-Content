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

-- no static tool

-- Chisel ( 737 )

-- raw stones (735)  --> stone blocks
-- stone blocks (733) --> small stones (1266)

local common = require("base.common")
local gathering = require("content.gathering")

module("content.gatheringcraft.stonecutting", package.seeall)

function StartGathering(User, SourceItem, ltstate)

	gathering.InitGathering();
	local stonecutting = gathering.stonecutting;
	-- we have to distinguish if we work on raw stones or stone blocks
	-- otherwise we would not be able to detect when to stop working on raw stones and the script would continue to work on stone blocks
	if ( WorkOnStone == nil ) then
		WorkOnStone = {}; -- an array that holds the id of the item we're working on for each user
		Stones = {};
		Stones[735] = {};
		Stones[735].productId = 733;
		Stones[735].amount = 1;
		Stones[735].nameDE = "rohen Steine";
		Stones[735].nameEN = "raw stones";

		Stones[733] = {};
		Stones[733].productId = 1266;
		Stones[733].amount = 10;
		Stones[733].nameDE = "Steinquader";
		Stones[733].nameEN = "stone blocks";
	end

	common.ResetInterruption( User, ltstate );
	if ( ltstate == Action.abort ) then -- work interrupted
		if (User:increaseAttrib("sex",0) == 0) then
			gText = "seine";
			eText = "his";
		else
			gText = "ihre";
			eText = "her";
		end
		User:talk(Character.say, "#me unterbricht "..gText.." Arbeit.", "#me interrupts "..eText.." work.")
		return
	end

--	if not common.CheckItem( User, SourceItem ) then -- security check
--		return
--	end

	-- additional tool item is needed
	if (User:countItemAt("all",737)==0) then
		common.HighInformNLS( User,
		"Du brauchst einen Mei�el um Steine zu behauen.",
		"You need a chisel for cutting stone." );
		return
	end
	local toolItem = User:getItemAt(5);
	if ( toolItem.id ~= 737 ) then
		toolItem = User:getItemAt(6);
		if ( toolItem.id ~= 737 ) then
			common.HighInformNLS( User,
			"Du musst den Mei�el in der Hand haben!",
			"You have to hold the chisel in your hand!" );
			return
		end
	end

	if not common.FitForWork( User ) then -- check minimal food points
		return
	end

	-- any other checks?

	if (User:countItemAt("all",733)==0 and User:countItemAt("all",735)==0) then -- check for items to work on
		common.HighInformNLS( User,
		"Du brauchst rohe Steine oder Steinquader um sie zu behauen.",
		"You need raw stones or stone blocks for cutting them." );
		return;
	end

	if ( ltstate == Action.none ) then -- currently not working -> let's go
		stonecutting.SavedWorkTime[User.id] = stonecutting:GenWorkTime(User, toolItem);
		User:startAction( stonecutting.SavedWorkTime[User.id], 0, 0, 0, 0);
		User:talk(Character.say, "#me beginnt Steine zu behauen.", "#me starts to cut stones.")
		-- save the item we're working on
		if ( User:countItemAt("all",735) > 0 ) then
			WorkOnStone[User.id] = 735; -- if there are raw stones, we work on those
		else
			WorkOnStone[User.id] = 733; -- no raw stones? Then there must be stone blocks
		end
		return
	end

	-- since we're here, we're working
	-- But do we still have the stone type we're really working on?
	if ( User:countItemAt("all",WorkOnStone[User.id]) == 0 ) then
		common.HighInformNLS( User,
		"Du hast keine " .. Stones[WorkOnStone[User.id]].nameDE .. " mehr.",
		"You have no " .. Stones[WorkOnStone[User.id]].nameEN .. " anymore." );
		return;
	end

	if stonecutting:FindRandomItem(User) then
		return
	end

	User:learn( stonecutting.LeadSkill, stonecutting.SavedWorkTime[User.id], stonecutting.LearnLimit);
	User:eraseItem( WorkOnStone[User.id], 1 ); -- erase the item we're working on
	local notCreated = User:createItem( Stones[WorkOnStone[User.id]].productId, Stones[WorkOnStone[User.id]].amount, 333, nil ); -- create the new produced items
	if ( notCreated > 0 ) then -- too many items -> character can't carry anymore
		world:createItemFromId( Stones[WorkOnStone[User.id]].productId, notCreated, User.pos, true, 333, nil );
		common.HighInformNLS(User,
		"Du kannst nichts mehr halten und der Rest f�llt zu Boden.",
		"You can't carry any more and the rest drops to the ground.");
	else -- character can still carry something
		if (User:countItemAt("all",WorkOnStone[User.id])>0) then  -- there are still items we can work on
			stonecutting.SavedWorkTime[User.id] = stonecutting:GenWorkTime(User, toolItem);
			User:startAction( stonecutting.SavedWorkTime[User.id], 0, 0, 0, 0);
		else -- no items left
			common.HighInformNLS( User,
			"Du hast keine " .. Stones[WorkOnStone[User.id]].nameDE .. " mehr.",
			"You have no " .. Stones[WorkOnStone[User.id]].nameEN .. " anymore." );
		end
	end

	if common.GatheringToolBreaks( User, toolItem, stonecutting:GenWorkTime(User, toolItem) ) then -- damage and possibly break the tool
		common.HighInformNLS(User,
		"Dein alter Mei�el zerbricht.",
		"Your old chisel breaks.");
		return
	end
end
