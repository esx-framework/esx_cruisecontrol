Config = {
    Locale = GetConvar('esx:locale', 'en'),
    HudResource = 'esx_hud',
    Cruise = {
        Enable = true,
        Key = "CAPITAL",
        Export = function (state)
            exports[Config.HudResource]:CruiseControlState(state)
        end,
    },
    Seatbelt = {
        Enable = true,
        Key = "B",
        Export = function (state)
            exports[Config.HudResource]:SeatbeltState(state)
        end
    }
}