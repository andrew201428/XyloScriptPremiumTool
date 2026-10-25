--[[
    XyloPremiumTool.lua
    Stage 1: Key System + Owner Bypass + Member Bypass
    Mobile + PC Supported
    Owner: Xylo
    -- [STAGE 2 INSERT HERE] -- (main GUI: aimbot/visuals/exploits/theme)
]]

-- ============================================================
-- CONFIG — EDIT MO ITO BAGO I-DRAG SA GITHUB
-- ============================================================
local CONFIG = {
    -- >>> PALITAN ITO NG ACTUAL ROBLOX USERID MO <<<
    OwnerUserIds = {
        10262160378, -- halimbawa: 123456789
    },

    -- >>> MEMBERS NA FREE ACCESS (Roblox UserId) <<<
    BypassUserIds = {
        -- 11470680857,
        -- 111222333,
    },

    -- >>> MEMBERS NA FREE ACCESS (Discord ID) <<<
    BypassDiscordIds = {
        -- "1487470700120903741",
        -- "987654321098765432",
    },

    -- >>> SECRET BYPASS CODES <<<
    BypassCodes = {
        ["XYLO-FREE-2026"] = true,   -- palitan mo kung gusto mo
        -- ["XYLO-VIP-001"] = true,
    },

    -- Discord invite
    DiscordInvite = "https://discord.gg/RuwJgZD4U",
    RequiredInvites = 5,
    KeyPrefix = "xylo",

    -- Theme colors
    Bg       = Color3.fromRGB(10, 10, 12),
    Panel    = Color3.fromRGB(18, 18, 22),
    Stroke   = Color3.fromRGB(45, 45, 55),
    Accent   = Color3.fromRGB(0, 200, 255),
    Success  = Color3.fromRGB(60, 220, 130),
    Pending  = Color3.fromRGB(255, 180, 60),
    Error    = Color3.fromRGB(255, 80, 80),
    Text     = Color3.fromRGB(235, 235, 240),
    SubText  = Color3.fromRGB(150, 150, 165),
    Font     = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
}

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- PLATFORM DETECT
-- ============================================================
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local SCREEN = workspace.CurrentCamera.ViewportSize
local UI_SCALE = IS_MOBILE and math.clamp(SCREEN.X / 720, 0.72, 1.10) or 1

-- ============================================================
-- SESSION
-- ============================================================
local SESSION = {
    userId = LocalPlayer.UserId,
    username = LocalPlayer.Name,
    displayName = LocalPlayer.DisplayName,
    requirementsMet = false,
    generatedKey = nil,
    isOwner = false,
    isBypassMember = false,
    bypassGranted = false,
}

-- ============================================================
-- UTIL
-- ============================================================
local function inList(list, val)
    for _, v in ipairs(list) do
        if v == val then return true end
    end
    return false
end

local function randomKey()
    local charset = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    local function seg(n)
        local out = {}
        for i = 1, n do
            local idx = math.random(1, #charset)
            out[i] = charset:sub(idx, idx)
        end
        return table.concat(out)
    end
    return "xylo-" .. seg(6) .. "-" .. seg(4)
end

local function tween(obj, props, dur)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

-- ============================================================
-- DETECT OWNER / BYPASS
-- ============================================================
SESSION.isOwner = inList(CONFIG.OwnerUserIds, SESSION.userId)
SESSION.isBypassMember = inList(CONFIG.BypassUserIds, SESSION.userId)

-- ============================================================
-- SCREEN GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XyloPremiumTool"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or CoreGui

-- ============================================================
-- MAIN FRAME
-- ============================================================
local Frame = Instance.new("Frame")
Frame.Name = "Main"
Frame.Size = UDim2.new(0, math.floor(780 * UI_SCALE), 0, math.floor(480 * UI_SCALE))
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = CONFIG.Bg
Frame.BackgroundTransparency = 1
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 14)
FrameCorner.Parent = Frame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = CONFIG.Stroke
FrameStroke.Thickness = 1
FrameStroke.Transparency = 1
FrameStroke.Parent = Frame

tween(Frame, { BackgroundTransparency = 0.05 }, 0.35)
tween(FrameStroke, { Transparency = 0 }, 0.35)

-- ============================================================
-- DRAG (mobile + PC)
-- ============================================================
local dragging, dragStart, startPos
local function bindDrag(handle)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
end

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================================
-- LEFT PANEL — USER INFO + LOGS
-- ============================================================
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, math.floor(250 * UI_SCALE), 1, 0)
LeftPanel.BackgroundColor3 = CONFIG.Panel
LeftPanel.BackgroundTransparency = 0.2
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = Frame
LeftPanel.ClipsDescendants = true

local LeftCorner = Instance.new("UICorner")
LeftCorner.CornerRadius = UDim.new(0, 14)
LeftCorner.Parent = LeftPanel

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, math.floor(48 * UI_SCALE), 0, math.floor(48 * UI_SCALE))
Avatar.Position = UDim2.new(0, 16, 0, 16)
Avatar.BackgroundColor3 = CONFIG.Panel
Avatar.Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(LocalPlayer.UserId)
Avatar.Parent = LeftPanel
Instance.new("UICorner", Avatar).CornerRadius = UDim.new(0, 8)

local NameLbl = Instance.new("TextLabel")
NameLbl.Size = UDim2.new(1, -80, 0, 20)
NameLbl.Position = UDim2.new(0, 72, 0, 16)
NameLbl.BackgroundTransparency = 1
NameLbl.Text = LocalPlayer.DisplayName
NameLbl.TextColor3 = CONFIG.Text
NameLbl.Font = CONFIG.FontBold
NameLbl.TextXAlignment = Enum.TextXAlignment.Left
NameLbl.TextSize = math.floor(14 * UI_SCALE)
NameLbl.Parent = LeftPanel

local UserLbl = Instance.new("TextLabel")
UserLbl.Size = UDim2.new(1, -80, 0, 16)
UserLbl.Position = UDim2.new(0, 72, 0, 38)
UserLbl.BackgroundTransparency = 1
UserLbl.Text = "@" .. LocalPlayer.Name .. "  •  " .. tostring(LocalPlayer.UserId)
UserLbl.TextColor3 = CONFIG.SubText
UserLbl.Font = CONFIG.Font
UserLbl.TextXAlignment = Enum.TextXAlignment.Left
UserLbl.TextSize = math.floor(10 * UI_SCALE)
UserLbl.Parent = LeftPanel

local LogsTitle = Instance.new("TextLabel")
LogsTitle.Size = UDim2.new(1, -32, 0, 16)
LogsTitle.Position = UDim2.new(0, 16, 0, 80)
LogsTitle.BackgroundTransparency = 1
LogsTitle.Text = "LOGS"
LogsTitle.TextColor3 = CONFIG.Accent
LogsTitle.Font = CONFIG.FontBold
LogsTitle.TextXAlignment = Enum.TextXAlignment.Left
LogsTitle.TextSize = math.floor(10 * UI_SCALE)
LogsTitle.Parent = LeftPanel

local LogsFrame = Instance.new("ScrollingFrame")
LogsFrame.Size = UDim2.new(1, -32, 0, 340)
LogsFrame.Position = UDim2.new(0, 16, 0, 102)
LogsFrame.BackgroundTransparency = 1
LogsFrame.BorderSizePixel = 0
LogsFrame.ScrollBarThickness = 3
LogsFrame.ScrollBarImageColor3 = CONFIG.Accent
LogsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogsFrame.Parent = LeftPanel

local LogLayout = Instance.new("UIListLayout")
LogLayout.Padding = UDim.new(0, 4)
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Parent = LogsFrame

local function addLog(txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 14)
    l.BackgroundTransparency = 1
    l.Text = "[Xylo] " .. txt
    l.TextColor3 = CONFIG.SubText
    l.Font = CONFIG.Font
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextSize = math.floor(10 * UI_SCALE)
    l.TextWrapped = true
    l.Parent = LogsFrame
    LogsFrame.CanvasSize = UDim2.new(0, 0, 0, LogLayout.AbsoluteContentSize.Y + 8)
    LogsFrame.CanvasPosition = Vector2.new(0, LogsFrame.CanvasSize.Y.Offset)
end

addLog("Session started")
addLog("Platform: " .. (IS_MOBILE and "Mobile" or "PC"))
addLog("User: " .. LocalPlayer.Name)
addLog("Loading...")

-- ============================================================
-- CENTER — KEY SYSTEM
-- ============================================================
local Center = Instance.new("Frame")
Center.Size = UDim2.new(1, -math.floor(266 * UI_SCALE), 1, 0)
Center.Position = UDim2.new(0, math.floor(266 * UI_SCALE), 0, 0)
Center.BackgroundTransparency = 1
Center.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 28)
Title.Position = UDim2.new(0, 24, 0, 20)
Title.BackgroundTransparency = 1
Title.Text = "Xylo Premium Tool"
Title.TextColor3 = CONFIG.Text
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextSize = math.floor(18 * UI_SCALE)
Title.Parent = Center

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -40, 0, 18)
SubTitle.Position = UDim2.new(0, 24, 0, 48)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Keyless verification"
SubTitle.TextColor3 = CONFIG.SubText
SubTitle.Font = CONFIG.Font
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.TextSize = math.floor(11 * UI_SCALE)
SubTitle.Parent = Center

-- Requirements container
local ReqFrame = Instance.new("Frame")
ReqFrame.Size = UDim2.new(1, -48, 0, 130)
ReqFrame.Position = UDim2.new(0, 24, 0, 80)
ReqFrame.BackgroundColor3 = CONFIG.Panel
ReqFrame.BackgroundTransparency = 0.2
ReqFrame.Parent = Center
Instance.new("UICorner", ReqFrame).CornerRadius = UDim.new(0, 10)

local ReqStroke = Instance.new("UIStroke")
ReqStroke.Color = CONFIG.Stroke
ReqStroke.Parent = ReqFrame

local function makeReq(y, label, action)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 36)
    row.Position = UDim2.new(0, 12, 0, y)
    row.BackgroundTransparency = 1
    row.Parent = ReqFrame

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, 0, 0.5, -5)
    dot.BackgroundColor3 = CONFIG.Pending
    dot.Parent = row
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -140, 1, 0)
    lbl.Position = UDim2.new(0, 22, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = CONFIG.Text
    lbl.Font = CONFIG.Font
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextSize = math.floor(12 * UI_SCALE)
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, math.floor(110 * UI_SCALE), 0, 28)
    btn.Position = UDim2.new(1, -math.floor(110 * UI_SCALE), 0.5, -14)
    btn.BackgroundColor3 = CONFIG.Accent
    btn.Text = action
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = math.floor(11 * UI_SCALE)
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    return { dot = dot, btn = btn }
end

local req1 = makeReq(10, "Boost SV 2x (Join Discord)", "Join")
local req2 = makeReq(58, "Invite 5 members", "Verify")

-- Get Key button
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(1, -48, 0, 42)
GetKeyBtn.Position = UDim2.new(0, 24, 0, 224)
GetKeyBtn.BackgroundColor3 = CONFIG.Accent
GetKeyBtn.Text = "GET KEY"
GetKeyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = math.floor(14 * UI_SCALE)
GetKeyBtn.Parent = Center
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 10)

-- Key display
local KeyDisplay = Instance.new("TextBox")
KeyDisplay.Size = UDim2.new(1, -48, 0, 38)
KeyDisplay.Position = UDim2.new(0, 24, 0, 278)
KeyDisplay.BackgroundColor3 = CONFIG.Panel
KeyDisplay.Text = "key will appear here"
KeyDisplay.TextColor3 = CONFIG.SubText
KeyDisplay.Font = Enum.Font.Code
KeyDisplay.TextSize = math.floor(13 * UI_SCALE)
KeyDisplay.ClearTextOnFocus = false
KeyDisplay.Parent = Center
Instance.new("UICorner", KeyDisplay).CornerRadius = UDim.new(0, 8)

-- Enter button
local EnterBtn = Instance.new("TextButton")
EnterBtn.Size = UDim2.new(1, -48, 0, 40)
EnterBtn.Position = UDim2.new(0, 24, 0, 328)
EnterBtn.BackgroundColor3 = CONFIG.Success
EnterBtn.Text = "ENTER TOOL"
EnterBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
EnterBtn.Font = Enum.Font.GothamBold
EnterBtn.TextSize = math.floor(13 * UI_SCALE)
EnterBtn.Visible = false
EnterBtn.Parent = Center
Instance.new("UICorner", EnterBtn).CornerRadius = UDim.new(0, 10)

-- "Have a code?" link
local CodeLink = Instance.new("TextButton")
CodeLink.Size = UDim2.new(1, -48, 0, 16)
CodeLink.Position = UDim2.new(0, 24, 0, 380)
CodeLink.BackgroundTransparency = 1
CodeLink.Text = "Have a bypass code?"
CodeLink.TextColor3 = CONFIG.SubText
CodeLink.Font = CONFIG.Font
CodeLink.TextSize = math.floor(10 * UI_SCALE)
CodeLink.Parent = Center

-- Hidden bypass code field
local CodeField = Instance.new("TextBox")
CodeField.Size = UDim2.new(1, -48, 0, 32)
CodeField.Position = UDim2.new(0, 24, 0, 402)
CodeField.BackgroundColor3 = CONFIG.Panel
CodeField.PlaceholderText = "Xylo-XXXX-XXXX"
CodeField.Text = ""
CodeField.TextColor3 = CONFIG.Accent
CodeField.PlaceholderColor3 = CONFIG.SubText
CodeField.Font = Enum.Font.Code
CodeField.TextSize = math.floor(12 * UI_SCALE)
CodeField.Visible = false
CodeField.Parent = Center
Instance.new("UICorner", CodeField).CornerRadius = UDim.new(0, 8)

-- Hidden Discord ID field
local DiscordField = Instance.new("TextBox")
DiscordField.Size = UDim2.new(1, -48, 0, 32)
DiscordField.Position = UDim2.new(0, 24, 0, 440)
DiscordField.BackgroundColor3 = CONFIG.Panel
DiscordField.PlaceholderText = "Discord ID (for bypass members)"
DiscordField.Text = ""
DiscordField.TextColor3 = CONFIG.Accent
DiscordField.PlaceholderColor3 = CONFIG.SubText
DiscordField.Font = Enum.Font.Code
DiscordField.TextSize = math.floor(12 * UI_SCALE)
DiscordField.Visible = false
DiscordField.Parent = Center
Instance.new("UICorner", DiscordField).CornerRadius = UDim.new(0, 8)

-- ============================================================
-- FLOW LOGIC
-- ============================================================
local req1Done, req2Done = false, false

local function checkRequirements()
    if req1Done and req2Done then
        SESSION.requirementsMet = true
        addLog("Requirements complete")
        tween(GetKeyBtn, { BackgroundColor3 = CONFIG.Success }, 0.2)
    end
end

local function generateAndShowKey(reason)
    if not SESSION.generatedKey then
        SESSION.generatedKey = randomKey()
    end
    KeyDisplay.Text = SESSION.generatedKey
    KeyDisplay.TextColor3 = CONFIG.Accent
    EnterBtn.Visible = true
    addLog("Key ready (" .. reason .. ")")
end

local function enterTool()
    addLog("Key accepted. Loading tool...")
    tween(Frame, { BackgroundTransparency = 1 }, 0.25)
    tween(FrameStroke, { Transparency = 1 }, 0.25)
    task.wait(0.3)
    Frame.Visible = false

    -- ============================================================
    -- [STAGE 2 INSERT HERE] -- main GUI (aimbot/visuals/exploits/theme)
    -- ============================================================

    -- Placeholder: sabihin sa user na stage 1 tapos na
    local msg = Instance.new("ScreenGui")
    msg.Name = "XyloStage1Msg"
    msg.ResetOnSpawn = false
    msg.IgnoreGuiInset = true
    msg.Parent = (gethui and gethui()) or CoreGui

    local mf = Instance.new("Frame")
    mf.Size = UDim2.new(0, 320, 0, 80)
    mf.Position = UDim2.new(0.5, 0, 0.5, 0)
    mf.AnchorPoint = Vector2.new(0.5, 0.5)
    mf.BackgroundColor3 = CONFIG.Bg
    mf.BackgroundTransparency = 0.05
    mf.Parent = msg
    Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 12)

    local mstroke = Instance.new("UIStroke")
    mstroke.Color = CONFIG.Accent
    mstroke.Parent = mf

    local mlbl = Instance.new("TextLabel")
    mlbl.Size = UDim2.new(1, -20, 1, -20)
    mlbl.Position = UDim2.new(0, 10, 0, 10)
    mlbl.BackgroundTransparency = 1
    mlbl.Text = "Xylo Stage 1 Loaded\nMain GUI coming in Stage 2"
    mlbl.TextColor3 = CONFIG.Text
    mlbl.Font = Enum.Font.GothamMedium
    mlbl.TextSize = 14
    mlbl.TextWrapped = true
    mlbl.Parent = mf

    task.delay(3, function()
        msg:Destroy()
    end)
end

-- Requirement 1: Discord join
req1.btn.MouseButton1Click:Connect(function()
    if req1Done then return end
    if setclipboard then setclipboard(CONFIG.DiscordInvite) end
    pcall(function()
        if request then
            request({ Url = CONFIG.DiscordInvite, Method = "GET" })
        end
    end)
    req1Done = true
    req1.dot.BackgroundColor3 = CONFIG.Success
    req1.btn.Text = "Done"
    req1.btn.BackgroundColor3 = CONFIG.Success
    addLog("Discord invite opened")
    checkRequirements()
end)

-- Requirement 2: Invite verify
req2.btn.MouseButton1Click:Connect(function()
    if not req1Done or req2Done then return end
    req2Done = true
    req2.dot.BackgroundColor3 = CONFIG.Success
    req2.btn.Text = "Verified"
    req2.btn.BackgroundColor3 = CONFIG.Success
    addLog("Invites verified (session)")
    checkRequirements()
end)

-- Get Key
GetKeyBtn.MouseButton1Click:Connect(function()
    -- Owner auto bypass
    if SESSION.isOwner then
        addLog("Owner detected")
        generateAndShowKey("owner")
        task.wait(0.4)
        enterTool()
        return
    end

    -- Bypass member (UserId)
    if SESSION.isBypassMember then
        addLog("Bypass member detected")
        generateAndShowKey("bypass-user")
        return
    end

    -- Normal flow
    if not SESSION.requirementsMet then
        addLog("Requirements pending")
        return
    end
    generateAndShowKey("requirements")
end)

-- Enter button
EnterBtn.MouseButton1Click:Connect(function()
    local input = KeyDisplay.Text
    if not input or input == "" then return end

    if SESSION.generatedKey and input == SESSION.generatedKey then
        enterTool()
        return
    end

    -- Secret code check
    if CONFIG.BypassCodes[input] then
        addLog("Bypass code accepted")
        SESSION.generatedKey = input
        enterTool()
        return
    end

    addLog("Invalid key")
end)

-- Code link toggle
CodeLink.MouseButton1Click:Connect(function()
    CodeField.Visible = not CodeField.Visible
    DiscordField.Visible = not DiscordField.Visible
end)

-- Code field submit
CodeField.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local code = CodeField.Text
    if CONFIG.BypassCodes[code] then
        addLog("Bypass code accepted")
        SESSION.generatedKey = code
        KeyDisplay.Text = code
        KeyDisplay.TextColor3 = CONFIG.Accent
        EnterBtn.Visible = true
        generateAndShowKey("bypass-code")
    else
        addLog("Invalid code")
    end
end)

-- Discord ID field submit
DiscordField.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local did = DiscordField.Text
    if inList(CONFIG.BypassDiscordIds, did) then
        addLog("Discord bypass accepted")
        generateAndShowKey("bypass-discord")
    else
        addLog("Discord ID not in bypass list")
    end
end)

-- ============================================================
-- OWNER SECRET TRIGGER: 5-click title
-- ============================================================
local titleClicks = 0
local lastClick = 0
local titleBtn = Instance.new("TextButton")
titleBtn.Size = UDim2.new(1, 0, 1, 0)
titleBtn.BackgroundTransparency = 1
titleBtn.Text = ""
titleBtn.Parent = Title

titleBtn.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastClick > 1.5 then
        titleClicks = 0
    end
    lastClick = now
    titleClicks = titleClicks + 1

    if titleClicks >= 5 then
        titleClicks = 0
        addLog("Secret trigger activated")
        SESSION.isOwner = true
        generateAndShowKey("secret-trigger")
        task.wait(0.4)
        enterTool()
    end
end)

-- ============================================================
-- AUTO BYPASS KUNG OWNER (pag-load pa lang)
-- ============================================================
if SESSION.isOwner then
    addLog("Owner detected. Auto-bypass.")
    task.wait(0.6)
    generateAndShowKey("owner-auto")
    task.wait(0.5)
    enterTool()
elseif SESSION.isBypassMember then
    addLog("Bypass member detected. Click GET KEY.")
else
    addLog("Waiting for requirements...")
end

-- ============================================================
-- DRAG BINDING
-- ============================================================
bindDrag(Title)
bindDrag(LeftPanel)