Config = {
    Locale = GetConvar('esx:locale', 'en'),
    HudResource = 'esx_hud',
    Cruise = {
        Enable = true,
        Key = "CAPITAL",
        Export = function (state)
            exports['esx_hud']:CruiseControlState(state)
        end,
    },
    Seatbelt = {
        Enable = true,
        Key = "B",
        Export = function (state)
            exports['esx_hud']:SeatbeltState(state)
        end
    }
}