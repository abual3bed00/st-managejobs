local QBCore = exports['qb-core']:GetCoreObject()

-- الصلاحيات المسموحة (حسب نظام QBCore Permissions)
local AllowedPerms = {
    ['admin'] = true,
    ['god'] = true
}

local function IsAuthorized(src)
    -- QBCore permissions (الأكثر استخداماً)
    if QBCore.Functions.HasPermission then
        for perm, _ in pairs(AllowedPerms) do
            if QBCore.Functions.HasPermission(src, perm) then
                return true
            end
        end
    end

    -- fallback لو عندك Ace perms (اختياري)
    if IsPlayerAceAllowed(src, 'qbcore.admin') or IsPlayerAceAllowed(src, 'command') then
        return true
    end

    return false
end

local function Deny(src)
    TriggerClientEvent('QBCore:Notify', src, "You are not allowed to do this", "error")
end

-- فتح الواجهة إن كان يملك صلاحية Admin (مش وظيفة)
RegisterNetEvent('jobgangmanager:requestOpenUI', function()
    local src = source

    if not IsAuthorized(src) then
        Deny(src)
        return
    end

    TriggerClientEvent('jobgangmanager:openUI', src)
end)

-- جعل الأداة تفتح الواجهة (برضه لازم صلاحية)
QBCore.Functions.CreateUseableItem('blaptop', function(source)
    if not IsAuthorized(source) then
        Deny(source)
        return
    end

    TriggerClientEvent('jobgangmanager:openUI', source)
end)

-- جلب الوظائف والعصابات (محمية)
RegisterNetEvent('jobgangmanager:getData', function()
    local src = source
    if not IsAuthorized(src) then
        Deny(src)
        return
    end

    local jobs, gangs = {}, {}

    for k, v in pairs(QBCore.Shared.Jobs) do
        table.insert(jobs, { name = k, label = v.label })
    end
    for k, v in pairs(QBCore.Shared.Gangs) do
        table.insert(gangs, { name = k, label = v.label })
    end

    TriggerClientEvent('jobgangmanager:returnData', src, { jobs = jobs, gangs = gangs })
end)

-- جلب رتب الوظيفة (محمية)
RegisterNetEvent('jobgangmanager:getJobGrades', function(job)
    local src = source
    if not IsAuthorized(src) then
        Deny(src)
        return
    end

    local grades = {}

    if QBCore.Shared.Jobs[job] and QBCore.Shared.Jobs[job].grades then
        for gradeNum, gradeData in pairs(QBCore.Shared.Jobs[job].grades) do
            table.insert(grades, { grade = tonumber(gradeNum), name = gradeData.name })
        end
        table.sort(grades, function(a, b) return a.grade < b.grade end)
    end

    TriggerClientEvent('jobgangmanager:returnJobGrades', src, grades)
end)

-- جلب رتب العصابة (محمية)
RegisterNetEvent('jobgangmanager:getGangGrades', function(gang)
    local src = source
    if not IsAuthorized(src) then
        Deny(src)
        return
    end

    local grades = {}

    if QBCore.Shared.Gangs[gang] and QBCore.Shared.Gangs[gang].grades then
        for gradeNum, gradeData in pairs(QBCore.Shared.Gangs[gang].grades) do
            table.insert(grades, { grade = tonumber(gradeNum), name = gradeData.name })
        end
        table.sort(grades, function(a, b) return a.grade < b.grade end)
    end

    TriggerClientEvent('jobgangmanager:returnGangGrades', src, grades)
end)

-- تعيين وظيفة (محمية)
RegisterNetEvent('jobgangmanager:assignJob', function(data)
    local src = source
    if not IsAuthorized(src) then
        Deny(src)
        return
    end

    local target = QBCore.Functions.GetPlayer(tonumber(data.id))
    if target then
        target.Functions.SetJob(data.job, tonumber(data.grade))
        TriggerClientEvent('QBCore:Notify', target.PlayerData.source, "Job assigned: " .. data.job .. " (Grade " .. data.grade .. ")", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Player not found", "error")
    end
end)

-- تعيين عصابة (محمية)
RegisterNetEvent('jobgangmanager:assignGang', function(data)
    local src = source
    if not IsAuthorized(src) then
        Deny(src)
        return
    end

    local target = QBCore.Functions.GetPlayer(tonumber(data.id))
    if target then
        target.Functions.SetGang(data.gang, tonumber(data.grade))
        TriggerClientEvent('QBCore:Notify', target.PlayerData.source, "Gang assigned: " .. data.gang .. " (Grade " .. data.grade .. ")", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Player not found", "error")
    end
end)
