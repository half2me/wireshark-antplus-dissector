local proto    = Proto("antplus", "ANT+")

local sync     = ProtoField.uint8("antplus.sync", "Sync", base.HEX)
local length   = ProtoField.uint8("antplus.length", "Payload Length", base.DEC)
local class    = ProtoField.uint8("antplus.class", "Class", base.HEX)
local payload  = ProtoField.protocol("antplus.payload", "Payload")
local checksum = ProtoField.uint8("antplus.checksum", "Checksum", base.HEX)

proto.fields   = { sync, length, class, payload, checksum }

function proto.dissector(buffer, pinfo, tree)
    -- guard for length
    local len = buffer:len()
    if len < 4 then return end

    pinfo.cols.protocol = proto.name

    local subtree = tree:add(proto, buffer(), "ANT+ Data")

    -- SYNC_TX
    subtree:add(sync, buffer(0, 1))

    -- LENGTH
    subtree:add(length, buffer(1, 1))

    -- Class
    subtree:add(class, buffer(2, 1))

    -- Payload
    local dissector = DissectorTable.get("antplus.class"):get_dissector(buffer(2, 1):uint()) or Dissector.get("data")
    dissector:call(buffer(3, len - 4):tvb(), pinfo, tree)

    -- Checksum
    subtree:add(checksum, buffer(len - 1, 1))
end

local function heuristic_checker(buffer, pinfo, tree)
    -- guard for length
    local len = buffer:len()
    if len < 4 then return false end

    -- match ANT TX_SYNC 0xA4 header
    if buffer(0, 1):uint() ~= 0xa4 then return false end

    -- check packet size is equal to payload length + 4 bytes to account for headers and checksum
    if len ~= buffer(1, 1):uint() + 4 then return false end

    proto.dissector(buffer, pinfo, tree)
    return true
end

proto:register_heuristic("usb.bulk", heuristic_checker)
DissectorTable.new("antplus.class", nil, ftypes.UINT8)
