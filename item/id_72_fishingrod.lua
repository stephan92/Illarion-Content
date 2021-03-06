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
-- UPDATE items SET itm_script='item.id_72_fishingrod' WHERE itm_id=72;

local common = require("base.common")
local fishing = require("content.gatheringcraft.fishing")
local wood = require("item.general.wood")

local M = {}

M.LookAtItem = wood.LookAtItem

function getWaterTilePosition(User)
	local targetPos = common.GetFrontPosition(User);
	if (common.GetGroundType(world:getField(targetPos):tile()) == common.GroundType.water) then
		return targetPos;
	end

	local Radius = 1;
	for x=-Radius,Radius do
		for y=-Radius,Radius do
			targetPos = position(User.pos.x + x, User.pos.y, User.pos.z);
			if (common.GetGroundType(world:getField(targetPos):tile()) == common.GroundType.water) then
				return targetPos;
			end
		end
	end
	return nil;
end

function getShoal(User)

	local targetItem = common.GetFrontItem(User);
	if (targetItem ~= nil and targetItem.id == 1170) then
		return targetItem;
	end

	local Radius = 1;
	for x=-Radius,Radius do
		for y=-Radius,Radius do
			local targetPos = position(User.pos.x + x, User.pos.y + y, User.pos.z);
			if (world:isItemOnField(targetPos)) then
				local targetItem = world:getItemOnField(targetPos);
				if (targetItem ~= nil and targetItem.id == 1170) then
					return targetItem;
				end
			end
		end
	end
	return nil;
end

function M.UseItem(User, SourceItem, ltstate)

	if (getWaterTilePosition(User) == nil) then -- fishing only possible on water tiles
		common.HighInformNLS(User,
		"Die Chance im Wasser einen Fisch zu fangen ist bedeutend h�her als auf dem Land.",
		"The chance to catch a fish is much higher in the water than on the land.");
		return
	end

	if (common.GetFrontPosition(User).z < 0) then -- fishing underground is not possible
		common.HighInformNLS(User,
		"In unterirdischen Wasserl�chern wird das Angeln kaum erfolgreich sein.",
		"Fishing in underground waterholes wouldn't be successful.");
		return
	end

	local shoalItem = getShoal(User);
	if (shoalItem == nil) then
		common.HighInformNLS(User,
		"Hier scheinen sich keine Fische zu befinden. Halte Ausschau nach einem Fischschwarm.",
		"There seems to be no fish here. Look for a shoal.");
		return
	end

	fishing.StartGathering(User, shoalItem, ltstate);
end

return M

