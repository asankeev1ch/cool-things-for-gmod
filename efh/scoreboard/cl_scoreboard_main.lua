if SERVER then return end

surface.CreateFont("EFH_UI_Big", { font = "Arial", size = 30, weight = 1000 })
surface.CreateFont("EFH_UI_Med", { font = "Arial", size = 20, weight = 800 })
surface.CreateFont("EFH_UI_Small", { font = "Arial", size = 16, weight = 800 })

local MainFrame
local ActivePage = nil
local ContentPanel

local ColBG = Color(0, 0, 0, 220)
local ColBtnNormal = Color(10, 10, 10, 255)
local ColBtnHover = Color(50, 50, 50, 255)
local ColMenuBG = Color(25, 25, 25, 255)

function EFH_OpenContextMenu()
    local menu = DermaMenu()
    
    menu.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, ColMenuBG)
        surface.SetDrawColor(255, 255, 255, 30)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    local oldAddOption = menu.AddOption
    menu.AddOption = function(s, text, func)
        local btn = oldAddOption(s, text, func)
        btn:SetFont("EFH_UI_Small")
        btn:SetTextColor(Color(200, 200, 200))
        btn.Paint = function(p, w, h)
            if p:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100, 50))
            end
        end
        return btn
    end
    
    return menu
end

local function SwitchPage(pageFunction)
    if IsValid(ActivePage) then ActivePage:Remove() end
    if not IsValid(ContentPanel) then return end
    
    if pageFunction then
        ActivePage = pageFunction(ContentPanel)
    end
end

local function OpenMenu()
    if IsValid(MainFrame) then MainFrame:Remove() end

    MainFrame = vgui.Create("DFrame")
    MainFrame:SetSize(ScrW(), ScrH())
    MainFrame:Center()
    MainFrame:SetTitle("")
    MainFrame:ShowCloseButton(false)
    MainFrame:SetDraggable(false)
    MainFrame:MakePopup()

    MainFrame.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, ColBG)
    end
    
    ContentPanel = vgui.Create("DPanel", MainFrame)
    ContentPanel:Dock(FILL)
    ContentPanel.Paint = function() end


    local btnSize = 60
    local btnGap = 0 
    local btnCount = 2
    local panelHeight = (btnSize * btnCount) + (btnGap * (btnCount - 1))
    
    local RightPanel = vgui.Create("DPanel", MainFrame)
    RightPanel:SetSize(btnSize, panelHeight)
    RightPanel:SetPos(ScrW() - btnSize, (ScrH() / 2) - (panelHeight / 2)) 
    RightPanel.Paint = function() end
    
    local function AddButton(index, text, func)
        local btn = vgui.Create("DButton", RightPanel)
        btn:SetSize(btnSize, btnSize)
        btn:SetPos(0, (index - 1) * (btnSize + btnGap))
        btn:SetText(text)
        btn:SetFont("EFH_UI_Small")
        btn:SetColor(color_white)
        btn.Paint = function(s, w, h)
            local col = s:IsHovered() and ColBtnHover or ColBtnNormal
            draw.RoundedBox(0, 0, 0, w, h, col)
            
            surface.SetDrawColor(255, 255, 255, 50)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
        btn.DoClick = function() SwitchPage(func) end
    end
    
    AddButton(1, "TAB", EFH_CreateScoreboardPage)
    AddButton(2, "INV", EFH_CreateInventoryPage)
    
    SwitchPage(EFH_CreateScoreboardPage)
end

local function CloseMenu()
    if IsValid(MainFrame) then MainFrame:Remove() end
end

hook.Add("ScoreboardShow", "EFH_OpenMenu", function()
    OpenMenu()
    return true
end)

hook.Add("ScoreboardHide", "EFH_CloseMenu", function()
    CloseMenu()
end)