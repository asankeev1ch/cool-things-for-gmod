if SERVER then return end

surface.CreateFont("EFH_ChatFont", {font = "Roboto", size = 20, weight = 600, extended = true, shadow = true})
surface.CreateFont("EFH_InputFont", {font = "Roboto", size = 22, weight = 500, extended = true})
surface.CreateFont("EFH_ChatLabel", {font = "Roboto", size = 18, weight = 800, shadow = true})

local chatFrame, historyPanel, inputPanel, inputText, scrollBar
local messages = {}
local isOpen, isTeamChat = false, false
local messageLifeTime = 12

local C_BG = Color(10, 10, 15, 230)
local C_INPUT = Color(30, 30, 35, 255)
local C_LABEL_SAY = Color(52, 152, 219)
local C_LABEL_TEAM = Color(46, 204, 113)

local function AddMarkupMessage(str)
    local finalStr = "<font=EFH_ChatFont>" .. str .. "</font>"
    
    local parsed = markup.Parse(finalStr, 580)
    
    table.insert(messages, { 
        markup = parsed, 
        time = CurTime(), 
        h = parsed:GetHeight() 
    })

    if isOpen and IsValid(scrollBar) then 
        scrollBar:AnimateTo(10000, 0.5, 0, -1) 
    end
end

local function CreateChatbox()
    if IsValid(chatFrame) then chatFrame:Remove() end

    chatFrame = vgui.Create("DFrame")
    chatFrame:SetSize(600, 400)
    chatFrame:SetPos(50, ScrH() - 500)
    chatFrame:SetTitle("")
    chatFrame:ShowCloseButton(false)
    chatFrame:SetDraggable(false)
    chatFrame.Paint = function(s, w, h)
        if isOpen then draw.RoundedBox(4, 0, 0, w, h, C_BG) end
    end

    historyPanel = vgui.Create("DPanel", chatFrame)
    historyPanel:SetPos(10, 10)
    historyPanel:SetSize(580, 330)
    
    scrollBar = vgui.Create("DVScrollBar", chatFrame)
    scrollBar:SetPos(585, 10)
    scrollBar:SetSize(10, 330)
    scrollBar:SetUp(1000, 1000)
    scrollBar.Paint = function() end
    scrollBar.btnGrip.Paint = function() end

    historyPanel.Paint = function(s, w, h)
        local y = h
        local totalHeight = 0
        
        for _, msg in ipairs(messages) do totalHeight = totalHeight + msg.h end
        
        if isOpen then
            scrollBar:SetUp(h, totalHeight)
            y = h + (totalHeight - h) - scrollBar:GetScroll()
        end

        for i = #messages, 1, -1 do
            local msg = messages[i]
            y = y - msg.h
            
            if isOpen and y + msg.h < 0 then continue end
            
            local alpha = 255
            if not isOpen then
                local timeDiff = CurTime() - msg.time
                if timeDiff > messageLifeTime then alpha = 0 
                elseif timeDiff > (messageLifeTime - 2) then alpha = 255 * ((messageLifeTime - timeDiff) / 2) end
            end
            
            if alpha > 10 then 
                msg.markup:Draw(0, y, 0, 0, alpha) 
            end
        end
    end

    inputPanel = vgui.Create("DPanel", chatFrame)
    inputPanel:Dock(BOTTOM)
    inputPanel:SetHeight(40)
    inputPanel:DockMargin(5, 0, 5, 5)
    inputPanel:SetVisible(false)
    inputPanel.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, C_INPUT) end

    inputPanel.lbl = inputPanel:Add("DLabel")
    inputPanel.lbl:Dock(LEFT)
    inputPanel.lbl:SetWidth(65)
    inputPanel.lbl:SetFont("EFH_ChatLabel")
    inputPanel.lbl:SetText(" SAY >")
    inputPanel.lbl:SetTextColor(C_LABEL_SAY)

    inputText = inputPanel:Add("DTextEntry")
    inputText:Dock(FILL)
    inputText:SetFont("EFH_InputFont")
    inputText:SetTextColor(color_white)
    inputText:SetDrawBorder(false)
    inputText:SetPaintBackground(false)
    inputText:SetHistoryEnabled(true)
    
    inputText.OnKeyCodeTyped = function(s, code)
        if code == KEY_ESCAPE then
            HideChat()
            gui.HideGameUI()
        elseif code == KEY_ENTER then
            local msg = string.Trim(s:GetValue())
            if msg ~= "" then
                if isTeamChat then
                    RunConsoleCommand("say_team", msg)
                else
                    RunConsoleCommand("say", msg)
                end
            end
            HideChat()
        end
    end
end

function ShowChat(bTeam)
    if not IsValid(chatFrame) then CreateChatbox() end
    
    isOpen = true
    isTeamChat = bTeam
    
    chatFrame:SetVisible(true)
    inputPanel:SetVisible(true)
    chatFrame:MakePopup()
    
    inputText:SetText("")
    inputText:RequestFocus()

    if bTeam then
        inputPanel.lbl:SetText(" TEAM >")
        inputPanel.lbl:SetTextColor(C_LABEL_TEAM)
    else
        inputPanel.lbl:SetText(" SAY >")
        inputPanel.lbl:SetTextColor(C_LABEL_SAY)
    end
end

function HideChat()
    if not IsValid(chatFrame) then return end
    isOpen = false
    inputPanel:SetVisible(false)
    
    chatFrame:SetMouseInputEnabled(false)
    chatFrame:SetKeyboardInputEnabled(false)
    gui.EnableScreenClicker(false)
end

hook.Add("StartChat", "EFH_OpenChat", function(bTeam)
    ShowChat(bTeam)
    return true
end)


hook.Add("FinishChat", "EFH_CloseChat", function()
    HideChat()
end)

hook.Add("ChatText", "EFH_HideDefault", function(index, name, text, type)
    if type == "joinleave" or type == "none" then
        AddMarkupMessage("<color=150,150,150>" .. text .. "</color>")
        return true
    end
    return true 
end)

hook.Add("HUDShouldDraw", "EFH_NoDefChat", function(name)
    if name == "CHudChat" then return false end
end)

hook.Add("OnPlayerChat", "EFH_AddMessage", function(ply, text, bTeam, bDead)
    if not IsValid(chatFrame) then CreateChatbox() end
    
    local str = ""
    
    if bDead then
        str = str .. "<color=231,76,60>*DEAD* </color>"
    end
    
    if bTeam then
        str = str .. "<color=46,204,113>(TEAM) </color>"
    end
    
    if IsValid(ply) then
        local col = team.GetColor(ply:Team())
        -- Форматируем ник цветом команды
        str = str .. string.format("<color=%d,%d,%d>%s</color>", col.r, col.g, col.b, ply:Nick())
        
        if ply:IsSuperAdmin() then
            str = "<color=255,215,0>[Admin] </color>" .. str
        end
    else
        str = str .. "<color=200,200,200>Console</color>"
    end
    
    str = str .. "<color=230,230,230>: " .. text .. "</color>"
    
    AddMarkupMessage(str)
    
    return true
end)

hook.Add("InitPostEntity", "EFH_InitChat", CreateChatbox)