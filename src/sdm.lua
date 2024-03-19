-- ANT+ Stride Based Speed and Distance Message
local proto               = Proto("antplus_sdm_message", "ANT+ SDM Message")

local page                = ProtoField.uint8("antplus_sdm_message.page", "Data Page Number", base.HEX)
local time                = ProtoField.float("antplus_sdm_message.time", "Sensor Time (s)")
local cumulative_distance = ProtoField.float("antplus_sdm_message.cumulative_distance", "Cumulative Distance (m)")

proto.fields              = {
    page,
    time,
    cumulative_distance,
}

function proto.dissector(buffer, pinfo, tree)
    -- guard for length
    local len = buffer:len()
    if len ~= 8 then return end

    local subtree = tree:add(proto, buffer(), "ANT+ SDM Message")

    -- DATA PAGE NUMBER
    local pageNum = buffer(0, 1):uint()
    subtree:add(page, buffer(0, 1))

    if pageNum == 0x01 then
        -- Time
        subtree:add(
            time, buffer(1, 2),
            buffer(2, 1):uint() + buffer(1, 1):uint() / 200
        )

        -- Accumulated Distance
        subtree:add(
            cumulative_distance, buffer(3, 2),
            buffer(3, 1):uint() + bit.rshift(buffer(4, 1):uint(), 4) / 16
        )
    elseif pageNum == 0x02 then
        -- decode data page #2
    end
end

DissectorTable.get("antplus.class"):add(0x7C, proto)
DissectorTable.get("antplus.broadcast.device_type"):add(0x7C, proto)
