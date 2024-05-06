local function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

local function report_spent(start)
    print(string.format("\telapsed time: %.2f\n", os.clock() - start))
end

local function tmemoize(func)
    return setmetatable({}, {
        __index = function(self, k)
            local v = func(k);
            self[k] = v
            return v;
        end
    });
end

local float_splitter = "."
local function str2float(str)
    local dot_index = string.find(str, float_splitter, 1, true)

    return math.tointeger(str:sub(0, dot_index - 1)) * 10 + math.tointeger(str:sub(dot_index + 1))
end

local splitter = ";"
local function split_line(line)
    local target_index = string.find(line, splitter, 1, true)

    local station = line:sub(0, target_index - 1)
    local temperature = line:sub(target_index + 1)

    return station,
        temperature
end

local function main()
    local filepath = './data/measurements.txt'
    local outpath = './output/results.txt'
    local start_time = os.clock()
    local stations = {}
    local station_names = {}
    local m_str2float = tmemoize(str2float)

    if not file_exists(filepath) then
        error("There is no measurements file")
    else
        print("File was found, process")
    end
    report_spent(start_time)

    for line in io.lines(filepath) do
        local station, tmp = split_line(line)
        local temperature = m_str2float[tmp]

        if stations[station] == nil then
            station_names[#station_names + 1] = station
            stations[station] = { count = 0, sum = 0, min = 100, max = -100 }
        else
            local stats = stations[station]
            stats['count'] = stats['count'] + 1                -- increase count by 1
            stats['sum'] = stats['sum'] + temperature          -- increase sum by `value`
            stats['min'] = math.min(stats['min'], temperature) -- running `min`
            stats['max'] = math.max(stats['max'], temperature) -- running `max`
        end
    end
    print("Processed stations")
    report_spent(start_time)

    table.sort(station_names)
    print("Stations sorted")
    report_spent(start_time)

    local out_file = assert(io.open(outpath, "w"))

    for k = 1, #station_names do
        local v = stations[station_names[k]]
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
