local Clock = {}

Clock.tasks = {}
Clock.animations = {}

Clock.time = 0

-- Util functions
local function schedule_task(task)
    for position, scheduled_object in pairs(Clock.tasks) do
        if (task.time <= scheduled_object.time) then
            table.insert(Clock.tasks, position, task)
            return
        end
    end
    table.insert(Clock.tasks, task)
end

local handle_task = {}
function handle_task.await(task)
    task.calback()
end

function handle_task.await_repeat(task)
    task.calback()
    task.time = task.time + task.interval
    schedule_task(task)
end

local function animate(tween, dt)
    if Clock.time > tween.time + tween.duration then
        if tween.calback then tween.calback() end
        return true
    elseif Clock.time >= tween.time then
        tween.elapsed = tween.elapsed + dt
        local percentage = math.min(tween.elapsed / tween.duration, 1)
        for key, value in pairs(tween.target) do
            tween.table[key] = tween.table[key] + ((value - tween.table[key]) * percentage)
            print(key, tween.table[key], percentage)
        end
    end
    return false
end

-- Api functions
--[[
    Await a time, then run a calback function
--]]
function Clock.await(time, calback)
    local new_o = {
        time = time + Clock.time,
        calback = calback,
        class = 'await'
    }
    schedule_task(new_o)
end

--[[
    Await a time, then run a calback function every interval
--]]
function Clock.await_repeat(start_time, interval, calback)
    local new_o = {
        time = start_time + Clock.time,
        interval = interval,
        calback = calback,
        class = 'await_repeat'
    }
    schedule_task(new_o)
end

--[[

--]]
function Clock.tween(start_time, duration, t, target, calback)
    local new_o = {
        time = start_time + Clock.time,
        duration = duration,
        elapsed = 0,
        table = t,
        target = target,
        calback = calback,
        class = 'tween'
    }
    table.insert(Clock.animations, new_o)
end

--[[
    Update the time, task and animations
--]]
function Clock.update(dt)
    Clock.time = Clock.time + dt
    -- Run task
    while 0 < #Clock.tasks do
        if Clock.tasks[1].time <= Clock.time then
            local executed_task = table.remove(Clock.tasks, 1)
            handle_task[executed_task.class](executed_task)
        else
            break
        end
    end
    -- Run animations
    for i = #Clock.animations, 1, -1 do
        if animate(Clock.animations[i], dt) then
            table.remove(Clock.animations, i)
        end
    end
end

return Clock