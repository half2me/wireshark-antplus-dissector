-- ANT+ Power Message
local proto                 = Proto("antplus_power_message", "ANT+ Power Message")

local page                  = ProtoField.uint8("antplus_power_message.page", "Data Page Number", base.HEX)
local event_count           = ProtoField.uint8("antplus_power_message.event_count", "Event Count", base.DEC)
local instantaneous_cadence = ProtoField.uint8(
    "antplus_power_message.instantaneous_cadence", "Instantaneous Cadence (rpm)", base.DEC
)
local acc_power             = ProtoField.uint16(
    "antplus_power_message.acc_power", "Accumulated Power (W)", base.DEC
)
local instantaneous_power   = ProtoField.uint16(
    "antplus_power_message.instantaneous_power", "Instantaneous Power (W)", base.DEC
)

proto.fields                = {
    page,
    event_count,
    instantaneous_cadence,
    acc_power,
    instantaneous_power
}

function proto.dissector(buffer, pinfo, tree)
    -- guard for length
    local len = buffer:len()
    if len ~= 8 then return end

    local cadence = buffer(3, 1):uint()
    --pinfo.cols.info = " PWR " .. cadence .. "rpm"

    local subtree = tree:add(proto, buffer(), "ANT+ Power Message")

    -- DATA PAGE NUMBER
    subtree:add(page, buffer(0, 1))

    -- EVENT COUNT
    subtree:add(event_count, buffer(1, 1))

    -- INSTANTANEOUS CADENCE
    subtree:add(instantaneous_cadence, buffer(3, 1))

    -- ACCUMULATED POWER
    subtree:add_le(acc_power, buffer(4, 2))

    -- INSTANTANEOUS POWER
    subtree:add_le(instantaneous_power, buffer(6, 2))
end

DissectorTable.get("antplus.class"):add(0x0B, proto)
DissectorTable.get("antplus.broadcast.device_type"):add(0x0B, proto)
