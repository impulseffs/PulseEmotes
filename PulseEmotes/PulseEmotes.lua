-- Create main addon frame
PulseEmotes = CreateFrame("Frame", "PulseEmotes", UIParent)
PulseEmotes:RegisterEvent("PLAYER_LOGIN")

-- List of emotes with verified commands for WoW 3.3.5a
local emotes = {
    {text = "Hello", command = "HELLO"},
    {text = "Chicken", command = "CHICKEN"},
    {text = "Laugh", command = "LAUGH"},
    {text = "Cry", command = "CRY"},
    {text = "Angry", command = "ANGRY"},
    {text = "Applaud", command = "APPLAUD"},
    {text = "Bow", command = "BOW"},
    {text = "Wave", command = "WAVE"},
    {text = "Dance", command = "DANCE"},
    {text = "Kiss", command = "KISS"},
    {text = "Shy", command = "SHY"},
    {text = "Cheer", command = "CHEER"},
    {text = "Flex", command = "FLEX"},
    {text = "Train", command = "TRAIN"},
    {text = "Roar", command = "ROAR"}
}

-- Addon info
local ADDON_INFO = {
    creator = "impulseffs",
    github = "https://github.com/impulseffs/PulseEmotes"
}

-- Function to display addon info
local function ShowAddonInfo()
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00PulseEmotes|r - Created by |cffff6600" .. ADDON_INFO.creator .. "|r")
    DEFAULT_CHAT_FRAME:AddMessage("Download at: |cff00ffff" .. ADDON_INFO.github .. "|r")
end

-- Chat command
SLASH_CHATBOTX1 = "/chatbotx"
SlashCmdList["CHATBOTX"] = function(msg)
    ShowAddonInfo()
end

-- Function to toggle the frame
local function ToggleEmoteFrame()
    if PulseEmotes.mainFrame:IsShown() then
        PulseEmotes.mainFrame:Hide()
    else
        PulseEmotes.mainFrame:Show()
    end
end

-- Create the main frame
local function CreateMainFrame()
    -- Calculate required frame height
    local buttonHeight = 25
    local spacing = 2
    local titleHeight = 30
    local padding = 15
    local totalButtonsHeight = (#emotes * (buttonHeight + spacing)) - spacing
    local frameHeight = totalButtonsHeight + titleHeight + (padding * 2)
    
    local frame = CreateFrame("Frame", "PulseEmotesFrame", UIParent)
    frame:SetWidth(180)
    frame:SetHeight(frameHeight)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    
    -- Make frame movable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    
    -- Create background
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)
    
    -- Create title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -8)
    title:SetText("|cff00ff00PulseEmotes|r")
    
    -- Create buttons container
    local buttonContainer = CreateFrame("Frame", nil, frame)
    buttonContainer:SetPoint("TOP", title, "BOTTOM", 0, -5)
    buttonContainer:SetWidth(160)
    buttonContainer:SetHeight(totalButtonsHeight)
    
    -- Create buttons
    for i, emote in ipairs(emotes) do
        local button = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
        button:SetWidth(150)
        button:SetHeight(buttonHeight)
        button:SetPoint("TOP", buttonContainer, "TOP", 0, -(i-1) * (buttonHeight + spacing))
        button:SetText(emote.text)
        button:SetScript("OnClick", function()
            DoEmote(emote.command)
        end)
        
        -- Custom button styling
        button:SetNormalFontObject("GameFontNormalSmall")
        button:GetNormalTexture():SetVertexColor(0.8, 0, 0) -- Red tint for buttons
    end
    
    -- Create close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeButton:SetScript("OnClick", function() frame:Hide() end)
    
    -- Create resize button
    local resizeButton = CreateFrame("Button", nil, frame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
    
    -- Create resize button texture
    local resizeTexture = resizeButton:CreateTexture(nil, "OVERLAY")
    resizeTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeTexture:SetAllPoints(resizeButton)
    resizeButton:SetNormalTexture(resizeTexture)
    
    local resizeTextureDown = resizeButton:CreateTexture(nil, "OVERLAY")
    resizeTextureDown:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeTextureDown:SetAllPoints(resizeButton)
    resizeButton:SetPushedTexture(resizeTextureDown)
    
    local resizeTextureHighlight = resizeButton:CreateTexture(nil, "OVERLAY")
    resizeTextureHighlight:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeTextureHighlight:SetAllPoints(resizeButton)
    resizeButton:SetHighlightTexture(resizeTextureHighlight)
    
    -- Make frame resizable
    frame:SetResizable(true)
    frame:SetMinResize(150, 100)
    frame:SetMaxResize(300, frameHeight)
    
    resizeButton:SetScript("OnMouseDown", function()
        frame:StartSizing("BOTTOMRIGHT")
    end)
    
    resizeButton:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
    end)
    
    frame:Hide()
    return frame
end

-- Create secure button for key binding
local function CreateSecureButton()
    local button = CreateFrame("Button", "PulseEmotesButton", UIParent, "SecureActionButtonTemplate")
    button:RegisterForClicks("AnyUp")
    button:SetScript("PreClick", function() 
        if PulseEmotes.mainFrame:IsShown() then
            PulseEmotes.mainFrame:Hide()
        else
            PulseEmotes.mainFrame:Show()
        end
    end)
    button:Hide()
    return button
end

-- Main event handler
function PulseEmotes:OnEvent(event, ...)
    if event == "PLAYER_LOGIN" then
        self.mainFrame = CreateMainFrame()
        self.secureButton = CreateSecureButton()
        
        -- Set up key binding
        SetBindingClick("INSERT", "PulseEmotesButton")
        
        -- Print loaded message and creator info
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00PulseEmotes|r: Loaded! Press Insert to show/hide emote menu.")
        ShowAddonInfo()
    end
end

PulseEmotes:SetScript("OnEvent", PulseEmotes.OnEvent)
