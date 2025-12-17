if SERVER then return end

surface.CreateFont("EFH_PickupFont", {
    font = "Arial",
    size = 20,
    weight = 800
})

local pickups = {}
local displayTime = 4 
local fadeTime = 1 

local function AddPickup(text)
    table.insert(pickups, {
        text = text,
        time = CurTime() + displayTime,
        alpha = 255
    })
end

hook.Add("HUDItemPickedUp", "EFH_ItemPick", function(itemName)
    AddPickup("+" .. language.GetPhrase(itemName))
end)

hook.Add("HUDWeaponPickedUp", "EFH_WepPick", function(wep)
    if IsValid(wep) then
        AddPickup("+" .. wep:GetPrintName())
    end
end)

hook.Add("HUDAmmoPickedUp", "EFH_AmmoPick", function(ammoName, amount)
    AddPickup("+" .. amount .. " " .. language.GetPhrase(ammoName .. "_ammo"))
end)

hook.Add("HUDPaint", "EFH_DrawPickups", function()
    local x = ScrW() - 20
    local y = ScrH() / 2
    local h = 30
    local padding = 5

    for i, data in ipairs(pickups) do
        local timeLeft = data.time - CurTime()
        
        if timeLeft < fadeTime then
            data.alpha = (timeLeft / fadeTime) * 255
        end
        
        if timeLeft <= 0 then
            table.remove(pickups, i)
        else
            surface.SetFont("EFH_PickupFont")
            local tw, th = surface.GetTextSize(data.text)
            local rw = tw + 20
            
            draw.RoundedBox(0, x - rw, y, rw, h, Color(0, 0, 0, math.min(200, data.alpha)))
            
            draw.SimpleText(data.text, "EFH_PickupFont", x - 10, y + h/2, Color(255, 255, 255, data.alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            
            y = y + h + padding
        end
    end
end)

hook.Add("HUDDrawPickupHistory", "EFH_NoDefPickups", function()
    return false
end)