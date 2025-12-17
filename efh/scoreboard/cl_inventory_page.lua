if SERVER then return end

local function CreateDollPanel(parent, targetEnt, isRagdoll)
    targetEnt = targetEnt or LocalPlayer()
    isRagdoll = isRagdoll or false
    
    local container = vgui.Create("DPanel", parent)
    container:Dock(FILL)
    container.Paint = function(s, w, h) 
        surface.SetDrawColor(30, 30, 30, 100)
        surface.DrawRect(0, 0, w, h)
    end

    local ModelPreview = vgui.Create("DModelPanel", container)
    ModelPreview:Dock(FILL)
    ModelPreview:SetModel(targetEnt:GetModel())
    ModelPreview:SetFOV(35)
    ModelPreview:SetCamPos(Vector(60, 0, 40))
    ModelPreview:SetLookAt(Vector(0, 0, 40))
    function ModelPreview:LayoutEntity(Entity) return end 

    local slotSize = 54

    local armorLayout = {
        { id = "sling",         x = -130, y = 20 }, 
        
        { id = "back_weapon",   x = 130,  y = 20 },

        { id = "head",          x = -slotSize - 5, y = -250 },
        { id = "visor",         x = 5,             y = -250 },
        { id = "eyes",          x = -slotSize - 5, y = -190 },
        { id = "face",          x = 5,             y = -190 },
        { id = "neck",          x = -slotSize/2,   y = -130 },

        { id = "body",          x = -slotSize - 60, y = 0 },
        { id = "rig",           x = 60,             y = 0 },

        { id = "l_shoulder",    x = -150, y = -60 },
        { id = "l_shoulder_back", x = -210, y = -60 }, 
        { id = "r_shoulder",    x = 150, y = -60 },
        { id = "r_shoulder_back", x = 210, y = -60 }, 

        { id = "backpack",      x = 150, y = 100 },

        { id = "groin",         x = -slotSize/2, y = 180 },
    }
    
    local nwPrefix = isRagdoll and "EFH_RagdollArmor_" or "EFH_Armor_"

    for _, cfg in ipairs(armorLayout) do
        local slot = vgui.Create("DButton", ModelPreview)
        slot:SetSize(slotSize, slotSize)
        slot:SetText("")
        
        slot.PerformLayout = function(s)
            local w, h = container:GetSize()
            s:SetPos((w/2) + cfg.x, (h/2) + cfg.y)
        end
        
        slot.Paint = function(s, w, h)
            local val = targetEnt:GetNWString(nwPrefix..cfg.id, "")
            local hasItem = (val ~= "" and val ~= "BLOCK")
            
            draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
            surface.SetDrawColor(hasItem and Color(200, 180, 50) or Color(60, 60, 60, 100))
            surface.DrawOutlinedRect(0, 0, w, h)
            draw.SimpleText(string.upper(cfg.id), "DermaDefault", w/2, h-10, Color(150,150,150,100), 1, 1)
            
            if hasItem then
                local itemCfg = EFH_Armor.List[val]
                if itemCfg then 
                    draw.SimpleText(string.sub(itemCfg.PrintName, 1, 8).."..", "DermaDefaultBold", 2, 5, Color(255,255,255), 0, 0) 
                else
                    draw.SimpleText("Unknown", "DermaDefault", 2, 5, Color(255,0,0), 0, 0) 
                end
            end
        end
        
        slot.DoClick = function()
            local val = targetEnt:GetNWString(nwPrefix..cfg.id, "")
            if val == "" or val == "BLOCK" then return end
            
            if isRagdoll then
                net.Start("EFH_Loot_TakeItem")
                net.WriteEntity(targetEnt)
                net.WriteString(cfg.id)
                net.SendToServer()
                surface.PlaySound("ui/buttonclick.wav")
            else
                local m = (EFH_OpenContextMenu and EFH_OpenContextMenu()) or DermaMenu()
                m:AddOption("Снять / Выбросить", function()
                    net.Start("EFH_UI_DropArmor")
                    net.WriteString(cfg.id)
                    net.SendToServer()
                end)
                m:Open()
            end
        end
    end
    
    return container
end

function EFH_CreateInventoryPage(parent)
    local p = vgui.Create("DPanel", parent)
    p:Dock(FILL)
    p.Paint = function() end
    
    CreateDollPanel(p, LocalPlayer(), false)
    
    return p
end

local LootFrame = nil

net.Receive("EFH_Loot_OpenMenu", function()
    local ragdoll = net.ReadEntity()
    if not IsValid(ragdoll) then return end
    
    if IsValid(LootFrame) then LootFrame:Remove() end
    
    if EFH_CloseMenu then EFH_CloseMenu() end

    LootFrame = vgui.Create("DFrame")
    LootFrame:SetSize(ScrW() * 0.8, ScrH() * 0.8)
    LootFrame:Center()
    LootFrame:SetTitle("LOOTING")
    LootFrame:MakePopup()
    LootFrame.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 240))
        Derma_DrawBackgroundBlur(s, 0)
    end
    
    local LeftPanel = vgui.Create("DPanel", LootFrame)
    LeftPanel:Dock(LEFT)
    LeftPanel:SetWide(LootFrame:GetWide() / 2)
    LeftPanel.Paint = function() end
    
    local lblL = vgui.Create("DLabel", LeftPanel); lblL:Dock(TOP); lblL:SetText(" ВЫ"); lblL:SetFont("DermaLarge"); lblL:SetContentAlignment(5)
    CreateDollPanel(LeftPanel, LocalPlayer(), false)
    
    local RightPanel = vgui.Create("DPanel", LootFrame)
    RightPanel:Dock(FILL)
    RightPanel.Paint = function() end
    
    local lblR = vgui.Create("DLabel", RightPanel); lblR:Dock(TOP); lblR:SetText(" ТРУП"); lblR:SetFont("DermaLarge"); lblR:SetContentAlignment(5)
    CreateDollPanel(RightPanel, ragdoll, true)
    
    LootFrame.Think = function(s)
        if not IsValid(ragdoll) or LocalPlayer():GetPos():DistToSqr(ragdoll:GetPos()) > 15000 then
            s:Close()
        end
    end
end)