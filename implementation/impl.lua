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
        stats = { count = 0, sum = 0, min = 100, max = -100 } -- count, sum, min=100, max=-100
    end


    stats['count'] = stats['count'] + 1      -- increase count by 1
    stats['sum'] = stats['sum'] + v          -- increase sum by `value`
    stats['min'] = math.min(stats['min'], v) -- running `min`
    stats['max'] = math.max(stats['max'], v) -- running `max`

    return stats
end

local float_splitter = string.byte('.')
local target_splitter = string.byte(';')
local function split_line(line)
    local target_index = -1
    local dot_index = -1

    for idx = 1, #line do
        if line:byte(idx) == target_splitter then
            target_index = idx
        end
        if target_index ~= -1 and line:byte(idx) == float_splitter then
            dot_index = idx
        end
    end

    return line:sub(0, target_index - 1),
        tonumber(line:sub(target_index + 1, dot_index - 1), 10) * 10 + tonumber(line:sub(dot_index + 1, #line), 10)
end

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
        local station, temperature = split_line(line)

        if stations[station] == nil then
            station_names[#station_names + 1] = station
            stations[station] = calc_one(stations[station], temperature)
        else
            calc_one(stations[station], temperature)
        end
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
    print("Result saved")
    report_spent(start_time)
    out_file:close()
end


print("=====")
print("Start")
print("=====")

main()

print("=====")
print(" End")
print("=====")
