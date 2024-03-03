-- ANT+ Speed & Cadence
local proto                               = Proto("antplus_speed_cadence_message", "ANT+ Speed & Cadence")

-- the time of the last valid cadence event (1/1024 sec)
local cadence_event_time                  = ProtoField.uint16(
    "antplus_speed_cadence_message.cadence_event_time", "Cadence Event Time (1/2024 sec)", base.DEC
)

-- the total number of pedal revolutions
local cumulative_cadence_revolution_count = ProtoField.uint16(
    "antplus_speed_cadence_message.cumulative_cadence_revolution_count", "Cumulative Cadence Revolution Count", base.DEC
)

-- the time of the last valid speed event (1/1024 sec)
local speed_event_time                    = ProtoField.uint16(
    "antplus_speed_cadence_message.speed_event_time", "Speed Event Time (1/2024 sec)", base.DEC
)

-- the total number of wheel revolutions
local cumulative_speed_revolution_count   = ProtoField.uint16(
    "antplus_speed_cadence_message.cumulative_speed_revolution_count", "Cumulative Speed Revolution Count", base.DEC
)

proto.fields                              = {
    cadence_event_time,
    cumulative_cadence_revolution_count,
    speed_event_time,
    cumulative_speed_revolution_count,
}

function proto.dissector(buffer, pinfo, tree)
    -- guard for length
    local len = buffer:len()
    if len ~= 8 then return end

    local subtree = tree:add(proto, buffer(), "ANT+ Speed & Cadence Message")

    subtree:add_le(cadence_event_time, buffer(0, 2))
    subtree:add_le(cumulative_cadence_revolution_count, buffer(2, 2))
    subtree:add_le(speed_event_time, buffer(4, 2))
    subtree:add_le(cumulative_speed_revolution_count, buffer(6, 2))
end

DissectorTable.get("antplus.class"):add(0x79, proto)
DissectorTable.get("antplus.broadcast.device_type"):add(0x79, proto)
