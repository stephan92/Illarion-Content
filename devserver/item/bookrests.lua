require("base.common")

-- UPDATE common SET com_script='item.bookrests' WHERE com_itemid = 3104;
-- UPDATE common SET com_script='item.bookrests' WHERE com_itemid = 3105;
-- UPDATE common SET com_script='item.bookrests' WHERE com_itemid = 3106;
-- UPDATE common SET com_script='item.bookrests' WHERE com_itemid = 3107;
-- UPDATE common SET com_script='item.bookrests' WHERE com_itemid = 3108;

module("item.bookrests", package.seeall)

function LookAtItem(User,Item)
	
	local lookAt 
	-- Bookrest for the Salavesh dungeon!
    if (Item.pos == position(741,406,-3)) then
	    lookAt = SalaveshLookAt(User, Item)
	end
	-- Salavesh end
	
	-- static teleporter
	if Item:getData("staticTeleporter") ~= "" then
		lookAt = StaticTeleporterLookAt(User, Item)
	end
	-- teleporter end
	
	if lookAt then
	    world:itemInform(User, Item, lookAt)
	else
	    world:itemInform(User, Item, base.lookat.GenerateLookAt(User, Item, 0))
	end	
end

function StaticTeleporterLookAt(User, Item)
	
	local lookAt = ItemLookAt();
	lookAt.name = "Teleporter";
	return lookAt
end

function SalaveshLookAt(User, Item)
    
	local lookAt = ItemLookAt();
	lookAt.rareness = ItemLookAt.rareItem;
		
	if (User:getPlayerLanguage()==0) then
		lookAt.name = "Tagebuch des Abtes Elzechiel";
		lookAt.description = "Dieses Buch ist von einer schaurigen Sch�nheit. Du bist versucht, es dennoch zu lesen..."
	else
		lookAt.name = "Journal of Abbot Elzechiel";
		lookAt.description = "This item has an evil presence. You are tempted to read it, though..."
	end
	return lookAt
end

function UseItem(User, SourceItem)
    -- Bookrest for the Salavesh dungeon!
    if (SourceItem.pos == position(741,406,-3)) then
	    User:sendBook(201);
	end
	-- Salavesh end
	
	-- static teleporter
	if SourceItem:getData("staticTeleporter") ~= "" then
	    StaticTeleporter(User, SourceItem)
	end
	-- static teleporter end
end

function StaticTeleporter(User, SourceItem)

    local names
	if  User:getPlayerLanguage() == Player.german then
		names = {"Runewick","Galmair","Cadomyr","Hanfschlinge"}
	else
		names = {"Runewick","Galmair","Cadomyr","Necktie"}
	end
	local items = {105,61,2701,1909}
	local targetPos = {position(788,826,0), position(424,245,0),position(127,647,0),position(684,307,0)}
	
	local callback = function(dialog)
	
		success = dialog:getSuccess()
		if success then
			selected = dialog:getSelectedIndex()
			if  base.money.CharHasMoney(User,1000) then
				
				if (targetPos[selected+1].x - SourceItem.pos.x) * (targetPos[selected+1].x - SourceItem.pos.x) < 10 then
					User:inform("Ihr befindet euch bereits in " ..names[selected+1]..".", "You are already in "..names[selected+1]..".")
				else
				
					User:inform("Ihr habt euch dazu entschlossen nach " ..names[selected+1].. " zu Reisen.", "You have chosen to travel to " ..names[selected+1]..".")
					base.money.TakeMoneyFromChar(User,1000)
					world:gfx(45,User.pos)
					world:makeSound(13,User.pos);
						
						
					User:warp(targetPos[selected+1])
					world:gfx(46,User.pos)
					world:makeSound(4,User.pos);
				end
			else
				User:inform("Ihr habt nicht genug Geld f�r diese Reise. Die Reise kostet zehn Silberst�cke.", "You don't have enough money for this journey. The journey costs ten silver coins.")
			end
		
		end
	end
		
	local dialog
	if User:getPlayerLanguage() == Player.german then
		dialog = SelectionDialog("Teleporter", "Eine Reise kostet zehn Silberst�cke. W�hle eine Ziel aus.", callback)
	else
		dialog = SelectionDialog("Teleporter", "A journey costs ten silver coins. Choose a destination.", callback)
	end
	dialog:setCloseOnMove()
	
	for i=1,#items do
		dialog:addOption(items[i], names[i])
	end
	User:requestSelectionDialog(dialog)
end