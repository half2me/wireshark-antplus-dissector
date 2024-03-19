-- ANT+ Stride Based Speed and Distance Message
local proto  = Proto("antplus_sdm_message", "ANT+ SDM Message")

local page   = ProtoField.uint8("antplus_sdm_message.page", "Data Page Number", base.HEX)

proto.fields = {
    page,
}

function proto.dissector(buffer, pinfo, tree)
    -- guard for length
    local len = buffer:len()
    if len ~= 8 then return end

    local subtree = tree:add(proto, buffer(), "ANT+ SDM Message")

    -- DATA PAGE NUMBER
    subtree:add(page, buffer(0, 1))
end

DissectorTable.get("antplus.class"):add(0x7C, proto)
DissectorTable.get("antplus.broadcast.device_type"):add(0x7C, proto)
