local cacheVeh, carArray, seatbelt, vehSpeed, previousVelocity = nil, {0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 17, 18, 19, 20}, false, 0.0, vector3(0,0,0)

local function setSeatbeltState(currentState)
	if not isHudReady or not exports[Config.UsedHud] then
		return
	end
	
	exports[Config.UsedHud]:SeatbeltState(currentState)
end

local function seatbeltLogic()
	local prevSpeed = vehSpeed
    vehSpeed = GetEntitySpeed(cacheVeh)

	local playerPed = ESX.PlayerData.ped
	local position = GetEntityCoords(playerPed)

    SetPedConfigFlag(playerPed, 32, true)

    if seatbelt then return end

    local isVehMovingFwd = GetEntitySpeedVector(cacheVeh, true).y > 1.0
    local vehAcceleration = (prevSpeed - vehSpeed) / GetFrameTime()

    if (isVehMovingFwd and (prevSpeed > (45/2.237)) and (vehAcceleration > (100*9.81))) then
        SetEntityCoords(playerPed, position.x, position.y, position.z - 0.47, true, true, true)
        SetEntityVelocity(playerPed, previousVelocity.x, previousVelocity.y, previousVelocity.z)
        SetPedToRagdoll(playerPed, 1000, 1000, 0, 0, 0, 0)
    else
        previousVelocity = GetEntityVelocity(cacheVeh)
	end
end

CreateThread(function()
	while currentVehicle do
		if not cacheVeh or cacheVeh ~= currentVehicle then
			local vehClass = GetVehicleClass(currentVehicle)
			for i = 1, #carArray do
				if carArray[i] == vehClass then
					cacheVeh = currentVehicle
					seatbeltLogic()
					return
				end
			end
		end
		seatbeltLogic()
		Wait(200)
	end
end)

ESX.RegisterInput('esx_cruisecontrol:ToggleSeatbelt', Translate('toggleSeatbelt'), "keyboard", Config.SeatbeltKey, function()
    if not currentVehicle then return end
    seatbelt = not seatbelt
	setSeatbeltState(seatbelt)
	ESX.ShowNotification(Translate(seatbelt and 'seatbeltOn' or 'seatbeltOff', 5000, 'info'))
end)

exports('isSeatbeltOn', function()
	return seatbelt
end)