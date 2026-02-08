local QBCore = exports['qb-core']:GetCoreObject()
local display = false

RegisterCommand('managejobs', function()
    TriggerServerEvent('jobgangmanager:requestOpenUI')
end)

RegisterNetEvent('jobgangmanager:openUI', function()
    display = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'toggleUI',
        show = true
    })
end)

RegisterNUICallback('close', function()
    display = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'toggleUI',
        show = false
    })
end)

-- استقبال طلبات الـ NUI وتمريرها للسيرفر
RegisterNUICallback('getData', function(data, cb)
    TriggerServerEvent('jobgangmanager:getData')
    RegisterNetEvent('jobgangmanager:returnData')
    AddEventHandler('jobgangmanager:returnData', function(data)
        cb(data)
    end)
end)

RegisterNUICallback('getJobGrades', function(data, cb)
    TriggerServerEvent('jobgangmanager:getJobGrades', data.job)
    RegisterNetEvent('jobgangmanager:returnJobGrades')
    AddEventHandler('jobgangmanager:returnJobGrades', function(grades)
        cb({grades = grades})
    end)
end)

RegisterNUICallback('getGangGrades', function(data, cb)
    TriggerServerEvent('jobgangmanager:getGangGrades', data.gang)
    RegisterNetEvent('jobgangmanager:returnGangGrades')
    AddEventHandler('jobgangmanager:returnGangGrades', function(grades)
        cb({grades = grades})
    end)
end)

RegisterNUICallback('assignJob', function(data, cb)
    TriggerServerEvent('jobgangmanager:assignJob', data)
    cb({})
end)

RegisterNUICallback('assignGang', function(data, cb)
    TriggerServerEvent('jobgangmanager:assignGang', data)
    cb({})
end)

-- إغلاق الواجهة بالـ ESC
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if display and IsControlJustPressed(0, 322) then -- زر ESC
            display = false
            SetNuiFocus(false, false)
            SendNUIMessage({
                action = 'toggleUI',
                show = false
            })
            TriggerServerEvent('jobgangmanager:close')
        end
    end
end)
