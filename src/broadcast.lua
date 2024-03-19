-- ANT+ Broadcast Message
local proto               = Proto("antplus_broadcast", "ANT+ Broadcast Message")

local channel             = ProtoField.uint8(
    "antplus_broadcast.channel", "Channel", base.DEC
)
local payload             = ProtoField.protocol(
    "antplus_broadcast.payload", "Payload"
)
local ext_flag            = ProtoField.uint8(
    "antplus_broadcast.ext_flag", "Extended Flag", base.HEX
)
local device_number       = ProtoField.uint16(
    "antplus_broadcast.device_number", "Device Number", base.DEC
)
local device_type         = ProtoField.uint8(
    "antplus_broadcast.device_type", "Device Type", base.HEX
)
local transmission_type   = ProtoField.uint8(
    "antplus_broadcast.brd_transmission_type", "Transmission Type", base.HEX
)

proto.fields              = {
    channel,
    payload,
    ext_flag,
    device_number,
    device_type,
    transmission_type
    --rssiMeasurementType:u8():hex(),
    --rssi:u8(),
    --rssiThreshold:u8(),
    --rxTimestamp:u16():le(),
}

local EXT_FLAG_CHANNEL_ID = 0x80
local EXT_FLAG_RSSI       = 0x40
local EXT_FLAG_TIMESTAMP  = 0x20

local function ant_msg_type(t)
    if t == 0x0B then
        return "ANT+ PWR"
    elseif t == 0x79 then
        return "ANT+ S&C"
    elseif t == 0x7C then
        return "ANT+ SDM"
    elseif t == 0x11 then
        return "ANT+ FE"
    end
    return t
end

function proto.dissector(buffer, pinfo, tree)
    -- guard for length
    local len = buffer:len()
    if len < 10 then return end

    -- TODO: fix to use little endian for correct device number
    pinfo.cols.info = "[" .. buffer(10, 2):le_uint() .. "] " .. ant_msg_type(buffer(12, 1):uint())

    local subtree = tree:add(proto, buffer(), "ANT+ Broadcast Message")

    -- CHANNEL
    subtree:add(channel, buffer(0, 1))

    -- Payload (8 bytes)
    local dissector = DissectorTable.get("antplus.broadcast.device_type"):get_dissector(buffer(12, 1):uint()) or
        Dissector.get("data")
    dissector:call(buffer(1, 8):tvb(), pinfo, tree)

    -- EXTFLAG
    subtree:add(ext_flag, buffer(9, 1))

    -- Extended Content -- TODO: make this part optional

    -- DEVICE NUMBER
    subtree:add_le(device_number, buffer(10, 2))

    -- Device Type
    subtree:add(device_type, buffer(12, 1))

    -- Transmission Type
    subtree:add(transmission_type, buffer(13, 1))
end

DissectorTable.get("antplus.class"):add(0x4E, proto)
DissectorTable.new("antplus.broadcast.device_type", nil, ftypes.UINT8)
