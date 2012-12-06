-- I_333 Horn spielen

-- UPDATE common SET com_script='item.id_333_horn' WHERE com_itemid=333;

require("item.base.music")
require("item.general.wood")

module("item.id_333_horn", package.seeall, package.seeall(item.general.wood))

item.base.music.addTalkText("#me 's cheeks turn red while blowing in a horn but no sound is audible","#me's Wangen werden beim Blasen in das Horn rot, aber kein Ton ist zu h�ren.","horn");
item.base.music.addTalkText("#me blows in a horn producing a buzzing sound","#me bl�st in das Horn und erzeugt ein summendes Ger�usch","horn");
item.base.music.addTalkText("#me blows in a horn, sounding like a dying animal","#me bl�st in das Horn und macht ein Ger�usch das wie ein sterbendes Tier klingt.","horn");
item.base.music.addTalkText("#me blows into a horn and produces a great sound","#me bl�st in das Horn und erzeugt so einen guten Klang","horn");
item.base.music.addTalkText("#me blows into a horn and produces a awesome sound","#me bl�st in das Horn und erzeugt einen beeindruckenden Klang","horn");

function UseItem(User,SourceItem,TargetItem,Counter,Param)
    item.base.music.PlayInstrument(User,SourceItem,"horn");
end