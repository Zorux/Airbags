-- CREATED BY ZORUX
-- CREATED BY ZORUX

-- Set carHealth to 100.0 to activate airbags when the vehicle is no longer drivable
-- This is recommended to stay between 700 - 999.0
-- Vehicles start at 1000.0 car health - then reduce
local carHealth = 700.0
-- This is the amount of seconds before the airbags automatically disappear - the /airbag command one does not disappear If you set this to -1, all airbags will stay forever, even when the vehicle is deleted 

local secondsToExpire = 160
local modelName = `prop_ld_binbag_01`

local vehicleairbags = {}
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped and GetVehicleEngineHealth(vehicle) <= carHealth and vehicleairbags[vehicle] == nil then
            local class = GetVehicleClass(vehicle)
            if class ~= 8 and class ~= 16 and class ~= 15 and class ~= 13 then
                createairbags(vehicle, true)
            end
        end
        Citizen.Wait(1000)
    end
end)

-- This command allows you to create permanent airbags on a vehicle 

RegisterCommand('airbag', function(source, args, rawCommand)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
        if vehicle ~= 0 then createairbags(vehicle, false) end
    end
end)

function createairbags(vehicle, temp)
    vehicleairbags[vehicle] = vehicle
    local driverSeat = GetEntityBoneIndexByName(vehicle, "seat_dside_f")
    local passengerSeat = GetEntityBoneIndexByName(vehicle, "seat_pside_f")
    local coords = GetEntityCoords(ped)
    local airbag1 = CreateObject(modelName, coords.x, coords.y, coords.z, true, true, true)
    local airbag2 = CreateObject(modelName, coords.x, coords.y, coords.z, true, true, true)
    while not DoesEntityExist(airbag1) or not DoesEntityExist(airbag2) do Wait(0) end
    SetModelAsNoLongerNeeded(modelName)
    AttachEntityToEntity(airbag1, vehicle, driverSeat, 0.0, 0.30, 0.40, 90.0, 0.0, 0.0, true, true, false, false, 2, true)
    AttachEntityToEntity(airbag2, vehicle, passengerSeat, 0.0, 0.40, 0.40, 90.0, 0.0, 0.0, true, true, false, false, 2, true)
    if temp then
        local deleted = false
        
        Citizen.SetTimeout(secondsToExpire * 1000, function()
            if not deleted then
                NetworkRequestControlOfEntity(airbag1)
                NetworkRequestControlOfEntity(airbag2)
                if DoesEntityExist(airbag1) then DeleteEntity(airbag1) end
                if DoesEntityExist(airbag2) then DeleteEntity(airbag2) end
                deleted = true
            end
        end)
        Citizen.CreateThread(function()
            while not deleted do
                if not DoesEntityExist(vehicle) then
                    NetworkRequestControlOfEntity(airbag1)
                    NetworkRequestControlOfEntity(airbag2)
                    if DoesEntityExist(airbag1) then DeleteEntity(airbag1) end
                    if DoesEntityExist(airbag2) then DeleteEntity(airbag2) end
                    deleted = true
                end
                Wait(1000)
            end
        end)
    end      
end

function loadModel(modelName)
    RequestModel(modelName)
    while not HasModelLoaded(modelName) do
        Wait(0)
    end
end

-- CREATED BY ZORUX