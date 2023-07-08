Utils = {
    ped = 0,
    vehicle = nil,
    driver = false,
    DriverCheck = function(self)
        if not self.Vehicle then return false end
        if not DoesEntityExist(self.Vehicle) then return false end
        if GetPedInVehicleSeat(self.Vehicle, -1) == self.Ped then
            return true
        end
        return false
    end,
    HudCheck = function(self)
        return GetResourceState(Config.HudResource) == 'started' and true or false
    end,
    SetHudState = function(self, state, seatbelt)
        if not self:HudCheck() then return end
        local settings = seatbelt and Config.Seatbelt or Config.Cruise
        if not settings.Enable then return end
        settings.Export(state)
        if seatbelt then return end
        ESX.ShowNotification(Translate(state and 'activated' or 'deactivated', 5000, 'info'))
    end,
    IsSteering = function(self)
        return GetVehicleSteeringAngle(self.Vehicle) > 10.0
    end,
    GetSpeed = function(self)
        if not self:DriverCheck() then return end
        local curSpeed = GetEntitySpeed(self.vehicle)
        return math.floor(curSpeed * 2.236936)
    end
}