require("content.craft.smithing")

module("item.id_172_anvil", package.seeall)

function UseItem(User, SourceItem, TargetItem, Counter, Param, ltstate)
    content.craft.smithing.smithing:showDialog(User, SourceItem)
end