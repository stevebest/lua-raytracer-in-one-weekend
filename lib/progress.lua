--- @class ProgressReport
--- @field private title string
--- @field private total_work integer
--- @field private work_done integer
--- @field private time_started number
--- @field private time_last_updated number
local ProgressReport = {}
ProgressReport.__index = ProgressReport

--- @param total_work integer
--- @param title string?
function ProgressReport:new(total_work, title)
    assert(type(total_work) == 'number')
    assert(total_work > 0)
    local now = os.time()
    local o = {
        title = title or "",
        total_work = total_work,
        work_done = 0,
        time_started = now,
        time_last_updated = now,
    }
    return setmetatable(o, self)
end

--- @param num integer
function ProgressReport:update(num)
    self.work_done = self.work_done + num
    local now = os.time()
    if now - self.time_last_updated > 5 then
        self:printreport()
    end
end

function ProgressReport:done()
    self:printreport()
end

local function formattime(sec)
    local d, h, m, s = 0, 0, 0, sec
    d, sec = sec // 86400, sec % 86400
    h, sec = sec // 3600, sec % 3600
    m, s = sec // 60, sec % 60
    if d > 0 then
        return string.format("%s d %02d:%02d:%02d", d, h, m, s)
    elseif h > 0 then
        return string.format("%02d:%02d:%02d", h, m, s)
    elseif m > 0 then
        return string.format("%02d:%02d", m, s)
    else
        return string.format("%d s", s)
    end
end

function ProgressReport:printreport()
    local percent = self.work_done / self.total_work * 100
    local now = os.time()
    self.time_last_updated = now
    local elapsed = now - self.time_started
    local avg = self.work_done / elapsed
    local eta = math.floor((self.total_work - self.work_done) / avg)
    if eta ~= eta then eta = 0 end
    local report = string.format(
        "%s: [ %s / %s ] %.2f%% avg = %.2f/s, elapsed = %s, eta = %s",
        self.title, self.work_done, self.total_work, percent, avg, formattime(elapsed), formattime(eta)
    )
    print(report)
end

return ProgressReport
