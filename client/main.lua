local cruiseActive, increasePressure, lastEngineHealth, currentCCSpeed, lastIdealPedalPressure, isDriver = false, false, 0, 0, 0.0, false
local speedDiffTolerance = (0.5 / 3.6)
local esx_hud = GetResourceState('esx_hud') == 'started' and true or false
currentVehicle = nil

local function driverCheck(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
        return true
    end
    return false
end

local function driverCheckThread()
    CreateThread(function()
        while currentVehicle and DoesEntityExist(currentVehicle) do
            isDriver = driverCheck(currentVehicle)
            Wait(1000)
        end
    end)
end

local function IsSteering()
    return GetVehicleSteeringAngle(currentVehicle) > 10.0
end

local function ApplyIdealPedalPressure()
    if not isDriver then return end
    if not cruiseActive then return end

    if not increasePressure then
        increasePressure = true
    end
    SetControlNormal(0, 71, lastIdealPedalPressure)
end

local function CalculateSpeed()
    if not isDriver then return end
    if not cruiseActive then return end

    local curSpeed = GetEntitySpeed(currentVehicle)
    return math.floor(curSpeed * 2.236936)
end

local function ChangeSpeed(state)
    if not isDriver then return end
    if not cruiseActive then return end

    local currentSpeed = CalculateSpeed()

    if state then
        if currentSpeed >= 120 then return end
        currentSpeed += 10
        currentCCSpeed = currentSpeed
    else
        if currentSpeed == 0 then return end
        currentSpeed += -10
        if currentSpeed < 0 then currentSpeed = 0 end
        currentCCSpeed = currentSpeed
    end
end

local function Reset()
    if not isDriver then return end
    if not cruiseActive then return end
    cruiseActive = false
    currentCCSpeed = 0
    lastEngineHealth = 0
    lastIdealPedalPressure = 0.0

    if esx_hud then
        exports.esx_hud:CruiseControlState(false)
    end

    ESX.ShowNotification(Translate('deactivated', 5000, 'info'))
end

local function Enable()
    if not isDriver then return end
    if cruiseActive then Reset() return end
    cruiseActive = true
    lastEngineHealth = GetVehicleEngineHealth(currentVehicle)

    CreateThread(function()
        currentCCSpeed = CalculateSpeed() or 0
        if currentCCSpeed == 0 then cruiseActive = false return end

        if esx_hud then
            exports.esx_hud:CruiseControlState(true)
        end

        ESX.ShowNotification(Translate('activated', 5000, 'info'))

        while cruiseActive do
            local engineHealth = GetVehicleEngineHealth(currentVehicle)

            if IsControlJustPressed(0, 72) or IsControlJustPressed(0, 76) then
                Reset()
            end

            if lastEngineHealth and ((lastEngineHealth - engineHealth) > 10) then
                Reset()
            else
                lastEngineHealth = engineHealth
            end

            local curSpeed = CalculateSpeed() or 0
            if curSpeed == 0 then Reset() return end

            local diff = currentCCSpeed - curSpeed

            if diff > speedDiffTolerance then
                local pedalPressure = 0.8

                if IsSteering() then
                    pedalPressure = 0.4
                end

                if increasePressure then
                    lastIdealPedalPressure = lastIdealPedalPressure + 0.025
                    increasePressure = false
                end

                SetControlNormal(0, 71, pedalPressure)
            elseif diff > - (4 * speedDiffTolerance) then
                ApplyIdealPedalPressure()
            else
                lastIdealPedalPressure = 0.2
            end

            Wait(0)
        end
    end)
end

AddEventHandler('esx:enteredVehicle', function(vehicle, plate, seat, displayName, netId)
    currentVehicle = vehicle
    driverCheckThread()
end)

AddEventHandler('esx:exitedVehicle', function(vehicle, plate, seat, displayName, netId)
    currentVehicle = nil
end)

ESX.RegisterInput('esx_cruisecontrol:Enable', Translate('cruiseControl'), "keyboard", Config.ToggleKey, function()
    if not currentVehicle then return end
    Enable()
end)

ESX.RegisterInput('esx_cruisecontrol:IncreaseSpeed', Translate('increaseSpeed'), "keyboard", "ADD", function()
    if not currentVehicle then return end
    ChangeSpeed(true)
end)

ESX.RegisterInput('esx_cruisecontrol:DecreaseSpeed', Translate('decreaseSpeed'), "keyboard", "SUBTRACT", function()
    if not currentVehicle then return end
    ChangeSpeed(false)
end)
