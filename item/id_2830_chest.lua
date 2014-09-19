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
-- UPDATE items SET itm_script='item.id_2830_chest' WHERE itm_id=2830;

local common = require("base.common")
local treasure = require("base.treasure")

local M = {}

function M.LookAtItem(User, Item)
    local TreasureName = treasure.GetTreasureName(tonumber(Item:getData("trsCat")), User:getPlayerLanguage(), false );
	base.lookat.SetSpecialDescription(Item,TreasureName, TreasureName);
	return base.lookat.GenerateLookAt(User, Item, base.lookat.NONE)
end

function M.UseItem(User,SourceItem)

    local level=tonumber(SourceItem:getData("trsCat"))
    local posi=SourceItem.pos;

    common.InformNLS(User, "Du �ffnest die Schatzkiste...", "You open the treasure chest...");
	world:erase(SourceItem,SourceItem.number); --strange hack here
	if (level ~= nil) and (level~=0) and (level < 10) then
        world:gfx(16,posi);
        world:makeSound(13,posi);
        treasure.SpawnTreasure( level, posi );
	else	
        common.InformNLS(User, "...sie ist leer!", "...it is empty!");
    end

end


return M

