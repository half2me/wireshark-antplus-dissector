-- ANT+ Fitness Message
local proto = Proto("antplus_fitness_message", "ANT+ Fitness Message")

local page  = ProtoField.uint8("antplus_fitness_message.page", "Data Page Number", base.HEX)


proto.fields = {
    page,
}

function proto.dissector(buffer, pinfo, tree)
    -- guard for length
    local len = buffer:len()
    if len ~= 8 then return end

    local subtree = tree:add(proto, buffer(), "ANT+ Fitness Message")

    -- DATA PAGE NUMBER
    local pageNum = buffer(0, 1):uint()
    subtree:add(page, buffer(0, 1))
end

DissectorTable.get("antplus.class"):add(0x11, proto)
DissectorTable.get("antplus.broadcast.device_type"):add(0x11, proto)
