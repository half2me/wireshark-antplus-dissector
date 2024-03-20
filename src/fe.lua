-- ANT+ Fitness Message
local proto               = Proto("antplus_fe_message", "ANT+ FE Message")

local page                = ProtoField.uint8("antplus_fe_message.page", "Data Page Number", base.HEX)
local equipment_type      = ProtoField.string("antplus_fe_message.equipment_type", "Equipment Type")
local elapsed_time        = ProtoField.float("antplus_fe_message.elapsed_time", "Elapsed Time (s)")
local distance_traveled   = ProtoField.uint8("antplus_fe_message.distance_traveled", "Distance Traveled (m)")
local speed               = ProtoField.float("antplus_fe_message.speed", "Instantaneous Speed (m/s)", base.DEC)
local hr                  = ProtoField.uint8("antplus_fe_message.heart_rate", "Heart Rate (bpm)")
local stroke_count        = ProtoField.uint8("antplus_fe_message.stroke_count", "Accumulated Stroke Count")
local instantaneous_power = ProtoField.uint16(
    "antplus_fe_message.instantaneous_power", "Instantaneous Power (W)", base.DEC
)


proto.fields = {
    page,
    equipment_type,
    elapsed_time,
    distance_traveled,
    speed,
    hr,
    stroke_count,
    instantaneous_power,
}

local function get_equipment_type(n)
    if n == 19 then
        return "Treadmill"
    elseif n == 20 then
        return "Elliptical"
    elseif n == 22 then
        return "Rower"
    elseif n == 23 then
        return "Climber"
    elseif n == 24 then
        return "Nordic Skier"
    elseif n == 25 then
        return "Trainer/Stationary Bike"
    else
        return "Unknown"
    end
end

function proto.dissector(buffer, pinfo, tree)
    -- guard for length
    local len = buffer:len()
    if len ~= 8 then return end

    local subtree = tree:add(proto, buffer(), "ANT+ FE Message")

    -- DATA PAGE NUMBER
    local pageNum = buffer(0, 1):uint()
    subtree:add(page, buffer(0, 1))

    if pageNum == 0x10 then
        -- General FE Data
        -- Equipment Type
        subtree:add(equipment_type, buffer(1, 1), get_equipment_type(buffer(1, 1):uint()))
        --- Elapsed Time
        subtree:add(elapsed_time, buffer(2, 1), buffer(2, 1):uint() / 4)
        --- Distance Traveled
        subtree:add(distance_traveled, buffer(3, 1))
        -- Instantaneous Speed
        local s = buffer(4, 2):le_uint()
        if s ~= 0xFFFF then -- 0xFFFF indicates invalid value
            subtree:add(speed, buffer(4, 2), s / 1000)
        end
        if buffer(6, 1):uint() ~= 0xFF then -- 0xFF indicates invalid value
            subtree:add(hr, buffer(6, 1))
        end
    elseif pageNum == 0x11 then
        -- TODO
    elseif pageNum == 0x12 then
        -- TODO
    elseif pageNum == 0x16 then
        -- Specific Rower Data
        -- Stroke Count
        subtree:add(stroke_count, buffer(3, 1))
        -- Instantaneous Power
        if buffer(5, 2):le_uint() ~= 0xFFFF then -- 0xFFFF indicates invalid value
            subtree:add_le(instantaneous_power, buffer(5, 2))
        end
    end
end

DissectorTable.get("antplus.class"):add(0x11, proto)
DissectorTable.get("antplus.broadcast.device_type"):add(0x11, proto)
