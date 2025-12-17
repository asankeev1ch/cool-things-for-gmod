if SERVER then return end

local Status = {
    Blood = 5000,
    HungerStart = 0,
    HungerDeath = 0
}

local VignetteAlpha = 0 
local ContusionBlur = 0  

net.Receive("EFH_SyncStatus", function()
    Status.Blood = net.ReadFloat()
    Status.HungerStart = net.ReadFloat()
    Status.HungerDeath = net.ReadFloat()
end)

net.Receive("EFH_DamageEvent", function()
    local alpha = net.ReadInt(9)
    local isContusion = net.ReadBool()
    
    VignetteAlpha = math.Clamp(alpha, 0, 255)
    
    if isContusion then
        ContusionBlur = 1.0 
    end
end)

hook.Add("RenderScreenspaceEffects", "EFH_Visuals", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then 
        VignetteAlpha = 0
        ContusionBlur = 0
        return 
    end

    local hp = ply:Health()
    local saturation = 1
    
    if hp <= 10 then
        saturation = 0
    else
        saturation = (hp - 10) / 90
    end
    saturation = math.Clamp(saturation, 0, 1)
    
    local tabHP = {
        ["$pp_colour_addr"] = 0, ["$pp_colour_addg"] = 0, ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = saturation,
        ["$pp_colour_mulr"] = 0, ["$pp_colour_mulg"] = 0, ["$pp_colour_mulb"] = 0
    }
    DrawColorModify(tabHP)

    local bloodLost = 5000 - Status.Blood
    if bloodLost > 500 then -- Начинаем мылить не сразу
        local blurAmount = (bloodLost / 3500) -- Плавное нарастание
        if blurAmount > 0 then
            DrawMotionBlur(0.1, blurAmount, 0.05)
        end
    end
    
    if Status.HungerStart > 0 and CurTime() > Status.HungerStart then
        local totalTime = Status.HungerDeath - Status.HungerStart
        local elapsed = CurTime() - Status.HungerStart
        local hungerFrac = math.Clamp(elapsed / totalTime, 0, 1)
        
        if hungerFrac > 0 then
            DrawToyTown(hungerFrac * 5, ScrH() * hungerFrac) 
            DrawSharpen(hungerFrac * 2, hungerFrac * 0.5)
        end
    end
    
    if ContusionBlur > 0 then
        DrawMotionBlur(0.2, ContusionBlur, 0.05)
        ContusionBlur = math.Approach(ContusionBlur, 0, FrameTime() * 0.1)
    end

    if ply:GetRunSpeed() > 450 then
        DrawSharpen(1.5, 0.5)
        local tab = {
            ["$pp_colour_addr"] = 0, ["$pp_colour_addg"] = 0, ["$pp_colour_addb"] = 0.05,
            ["$pp_colour_brightness"] = 0.05,
            ["$pp_colour_contrast"] = 1.1,
            ["$pp_colour_colour"] = 1.2,
            ["$pp_colour_mulr"] = 0, ["$pp_colour_mulg"] = 0, ["$pp_colour_mulb"] = 0
        }
        DrawColorModify(tab)
    end
end)

local matGradientL = Material("vgui/gradient-l")
local matGradientR = Material("vgui/gradient-r")
local matGradientU = Material("vgui/gradient-u")
local matGradientD = Material("vgui/gradient-d")

hook.Add("HUDPaint", "EFH_DamageVignetteDraw", function()
    if VignetteAlpha > 0 then
        local w, h = ScrW(), ScrH()
        
        surface.SetDrawColor(0, 0, 0, VignetteAlpha)
        surface.DrawRect(0, 0, w, h)
        
        /*
        surface.SetDrawColor(0, 0, 0, VignetteAlpha)
        surface.SetMaterial(matGradientL); surface.DrawTexturedRect(0, 0, w*0.3, h)
        surface.SetMaterial(matGradientR); surface.DrawTexturedRect(w*0.7, 0, w*0.3, h)
        surface.SetMaterial(matGradientU); surface.DrawTexturedRect(0, 0, w, h*0.3)
        surface.SetMaterial(matGradientD); surface.DrawTexturedRect(0, h*0.7, w, h*0.3)
        */

        VignetteAlpha = math.Approach(VignetteAlpha, 0, FrameTime() * 100)
    end
end)