if SERVER then return end

surface.CreateFont("EFH_WepFont", {
    font = "Arial",
    size = 16,
    weight = 800
})

surface.CreateFont("EFH_WepNumber", {
    font = "Arial",
    size = 24,
    weight = 800
})

local selector = {
    open = false,
    alpha = 0,
    curSlot = 1,
    curPos = 1,  
    stayTime = 0
}

local SLOT_COUNT = 6
local BOX_WIDTH = 140
local BOX_HEIGHT = 40
local GAP = 5

local function GetWeaponMap()
    local map = {}
    for i = 1, SLOT_COUNT do map[i] = {} end
    
    for _, wep in ipairs(LocalPlayer():GetWeapons()) do
        -- GetSlot() возвращает 0 для слота 1, поэтому +1
        local slot = wep:GetSlot() + 1
        if slot >= 1 and slot <= SLOT_COUNT then
            table.insert(map[slot], wep)
        end
    end
    return map
end

local function OpenSelector()
    selector.open = true
    selector.alpha = 255
    selector.stayTime = CurTime() + 2
end

local function ConfirmSelection()
    local map = GetWeaponMap()
    local wepsInSlot = map[selector.curSlot]
    
    if wepsInSlot and wepsInSlot[selector.curPos] then
        input.SelectWeapon(wepsInSlot[selector.curPos])
        LocalPlayer():EmitSound("common/wpn_select.wav")
    end
    
    selector.open = false
    selector.alpha = 0
end

hook.Add("PlayerBindPress", "EFH_WepSelectBind", function(ply, bind, pressed)
    if not pressed then return end

    if bind:StartWith("slot") then
        local slotNum = tonumber(bind:sub(5))
        if not slotNum then return end

        local map = GetWeaponMap()
        
        if not selector.open or selector.curSlot ~= slotNum then
            if #map[slotNum] > 0 then
                selector.curSlot = slotNum
                selector.curPos = 1 -- Сбрасываем на первое оружие в слоте
                OpenSelector()
                ply:EmitSound("common/wpn_moveselect.wav")
            end
        else
            if #map[slotNum] > 1 then
                selector.curPos = selector.curPos + 1
                if selector.curPos > #map[slotNum] then selector.curPos = 1 end
                OpenSelector()
                ply:EmitSound("common/wpn_moveselect.wav")
            end
        end
        return true
    end

    if bind == "invnext" or bind == "invprev" then
        local map = GetWeaponMap()
        
        if not selector.open then
            OpenSelector()
            local activeWep = ply:GetActiveWeapon()
            if IsValid(activeWep) then
                selector.curSlot = activeWep:GetSlot() + 1
                for k, v in ipairs(map[selector.curSlot] or {}) do
                    if v == activeWep then selector.curPos = k break end
                end
            end
        end

        local dir = (bind == "invnext") and 1 or -1

        if dir == 1 then -- Вниз
            selector.curPos = selector.curPos + 1
            if not map[selector.curSlot] or selector.curPos > #map[selector.curSlot] then
                local origSlot = selector.curSlot
                repeat
                    selector.curSlot = selector.curSlot + 1
                    if selector.curSlot > SLOT_COUNT then selector.curSlot = 1 end
                until (#map[selector.curSlot] > 0) or (selector.curSlot == origSlot)
                selector.curPos = 1
            end
        else 
            selector.curPos = selector.curPos - 1
            if selector.curPos < 1 then
                local origSlot = selector.curSlot
                repeat
                    selector.curSlot = selector.curSlot - 1
                    if selector.curSlot < 1 then selector.curSlot = SLOT_COUNT end
                until (#map[selector.curSlot] > 0) or (selector.curSlot == origSlot)
                selector.curPos = #map[selector.curSlot] -- Последнее оружие в слоте
            end
        end
        
        OpenSelector()
        ply:EmitSound("common/wpn_moveselect.wav")
        return true
    end

    if bind == "+attack" and selector.open then
        ConfirmSelection()
        return true
    end
end)

hook.Add("HUDPaint", "EFH_DrawTopSelector", function()
    if not selector.open then return end

    if CurTime() > selector.stayTime then
        selector.alpha = math.Approach(selector.alpha, 0, FrameTime() * 400)
        if selector.alpha <= 0 then selector.open = false return end
    end

    local map = GetWeaponMap()
    local totalWidth = (SLOT_COUNT * BOX_WIDTH) + ((SLOT_COUNT - 1) * GAP)
    local startX = (ScrW() / 2) - (totalWidth / 2)
    local startY = 20

    for i = 1, SLOT_COUNT do
        local x = startX + (i - 1) * (BOX_WIDTH + GAP)
        local hasWeapons = #map[i] > 0
        local isSelectedSlot = (i == selector.curSlot)

        local colBox = Color(10, 10, 10, selector.alpha * 0.8)
        local colText = Color(100, 100, 100, selector.alpha)
        
        if hasWeapons then
            colText = Color(255, 255, 255, selector.alpha)
        end
        
        if isSelectedSlot then
            colBox = Color(255, 255, 255, selector.alpha)
            colText = Color(0, 0, 0, selector.alpha)
        end

        draw.RoundedBox(0, x, startY, BOX_WIDTH, BOX_HEIGHT, colBox)
        
        draw.SimpleText(tostring(i), "EFH_WepNumber", x + 10, startY + BOX_HEIGHT/2, colText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        if hasWeapons then
            local wep = map[i][isSelectedSlot and selector.curPos or 1]
            if wep then
                local name = string.upper(wep:GetPrintName())
                if string.len(name) > 15 then name = string.sub(name, 1, 13) .. ".." end
                
                draw.SimpleText(name, "EFH_WepFont", x + BOX_WIDTH - 10, startY + BOX_HEIGHT/2, colText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                
                if #map[i] > 1 and isSelectedSlot then
                     draw.SimpleText(selector.curPos.."/"..#map[i], "EFH_WepFont", x + BOX_WIDTH/2, startY - 15, Color(255, 255, 255, selector.alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end
    end
end)

hook.Add("HUDShouldDraw", "EFH_HideDefWep", function(name)
    if name == "CHudWeaponSelection" then return false end
end)