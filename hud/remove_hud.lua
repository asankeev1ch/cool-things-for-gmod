local hideElements = {
    ["CHudHealth"] = true,          
    ["CHudBattery"] = true,         
    ["CHudAmmo"] = true,           
    ["CHudSecondaryAmmo"] = true,   
    ["CHudCrosshair"] = true        
}

hook.Add("HUDShouldDraw", "EFH_HideStandardHUD", function(name)
    -- Если имя элемента есть в нашей таблице - возвращаем false (не рисовать)
    if hideElements[name] then
        return false
    end
end)