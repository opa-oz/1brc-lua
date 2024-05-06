local function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

local function report_spent(start)
    print(string.format("\telapsed time: %.2f\n", os.clock() - start))
end

local function calc_one(stats, v)
    if stats == nil then
        stats = { count = 0, sum = 0, min = 1 / 0, max = -100 } -- count, sum, min=Infinity, max=-100
    end


    stats['count'] = stats['count'] + 1      -- increase count by 1
    stats['sum'] = stats['sum'] + v          -- increase sum by `value`
    stats['min'] = math.min(stats['min'], v) -- running `min`
    stats['max'] = math.max(stats['max'], v) -- running `max`

    return stats
end

local float_splitter = string.byte('.')
local function str2float(str)
    local dot_index = -1
    for idx = 1, #str do
        if str:byte(idx) == float_splitter then
            dot_index = idx
            break
        end
    end

    return tonumber(str:sub(0, dot_index - 1), 10) * 10 + tonumber(str:sub(dot_index + 1, #str), 10)
end

local target_splitter = string.byte(';')
local function split_line(line)
    local target_index = -1
    for idx = 1, #line do
        if line:byte(idx) == target_splitter then
            target_index = idx
            break
        end
    end

    return line:sub(0, target_index - 1), line:sub(target_index + 1, #line)
end

-- calculate
--  `count`
--  `sum`
--  `min`
--  `max`
local function main()
    local filepath = './data/measurements.txt'
    local outpath = './output/results.txt'
    local start_time = os.clock()
    local stations = {}
    local station_names = {}

    if not file_exists(filepath) then
        error("There is no measurements file")
    else
        print("File was found, process")
    end
    report_spent(start_time)

    for line in io.lines(filepath) do
        local station, tmp = split_line(line)
        local temperature = str2float(tmp)

        if stations[station] == nil then
            station_names[#station_names + 1] = station
        end
        stations[station] = calc_one(stations[station], temperature)
    end
    print("Processed stations")
    report_spent(start_time)

    table.sort(station_names)
    print("Stations sorted")
    report_spent(start_time)

    local out_file = assert(io.open(outpath, "w"))

    for _, k in ipairs(station_names) do
        local v = stations[k]
        out_file:write(k)
        out_file:write(";")
        out_file:write(
            v['min'] / 10 + 0.0
        )
        out_file:write(";")
        out_file:write(
            string.format("%.2f", v['sum'] / v['count'] / 10 + 0.0)
        )
        out_file:write(";")
        out_file:write(
            v['max'] / 10 + 0.0
        )

        out_file:write('\n')
    end

    out_file:close()
end


print("=====")
print("Start")
print("=====")

main()

print("=====")
print(" End")
print("=====")
