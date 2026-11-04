!nocheck
-- SyzenHub v3.0 - Complete Optimized Source Code
local cloneref = cloneref or function(o) return o end
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local TextService = cloneref(game:GetService("TextService"))
local HttpService = cloneref(game:GetService("HttpService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local LocalPlayer = Players.LocalPlayer local Mouse = LocalPlayer:GetMouse()
local Env = {
Connections = {},
PagesList = {},
Icons = {
["general"] = "rbxassetid://101849161408766",
["auto"] = "rbxassetid://110162136250435",
["setting"] = "rbxassetid://72210587662292",
["settings"] = "rbxassetid://10734950309",
["misc"] = "rbxassetid://84034775913393",
["items"] = "rbxassetid://98574803492996",
["shop"] = "rbxassetid://74630923244478",
["teleport"] = "rbxassetid://137847566773112",
["visual"] = "rbxassetid://123257335719276",
["visuals"] = "rbxassetid://10723346959",
["combat"] = "rbxassetid://112935442242481",
["update"] = "rbxassetid://86844430363710",
["home"] = "rbxassetid://10723407389",
["user"] = "rbxassetid://10747373176",
["shield"] = "rbxassetid://10734951847",
["sword"] = "rbxassetid://10734975486",
["sparkles"] = "rbxassetid://10734966248",
["zap"] = "rbxassetid://10747384394",
["eye"] = "rbxassetid://10723346959",
["search"] = "rbxassetid://10734943674",
["check"] = "rbxassetid://86682186031062",
["bell"] = "rbxassetid://10709775704",
["heart"] = "rbxassetid://10723406885",
["lock"] = "rbxassetid://10723434711",
["unlock"] = "rbxassetid://10747366027",
["trash"] = "rbxassetid://10747362393",
["copy"] = "rbxassetid://10709812159",
["discord"] = "rbxassetid://94937742565147",
["arrow_right"] = "rbxassetid://108028847031522",
["dropdown"] = "rbxassetid://129573215183311",
["code"] = "rbxassetid://10709810463",
["sliders"] = "rbxassetid://10734963400",
["globe"] = "rbxassetid://10723404337",
["cpu"] = "rbxassetid://10709813383"
}
}
local function RandomName()
local ok, id = pcall(function()
return HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 10)
end)
return (ok and id) or tostring(math.random(100000, 999999)) end
local function GetSafeGuiParent()
if RunService:IsStudio() then
return LocalPlayer:WaitForChild("PlayerGui")
end
if gethui then
return gethui()
elseif syn and syn.protect_gui then
local folder = Instance.new("Folder")
syn.protect_gui(folder)
folder.Name = RandomName()
folder.Parent = CoreGui
return folder
end
return CoreGui
end
local function TrackConn(conn)
table.insert(Env.Connections, conn)
return conn
end
local function GetIcon(i)
if not i then return "" end
if type(i) == "number" then
return "rbxassetid://" .. tostring(i)
elseif type(i) == "string" then
local lower = string.lower(i)
if Env.Icons[lower] then
return Env.Icons[lower]
elseif i:find("rbxassetid://") then
return i
elseif tonumber(i) then
return "rbxassetid://" .. i
end
end
return tostring(i)
end
local function tw(info)
local style = Enum.EasingStyle[info.s or "Quart"] or Enum.EasingStyle.Quart
local dir = Enum.EasingDirection[info.d or "Out"] or
Enum.EasingDirection.Out
return TweenService:Create(info.v, TweenInfo.new(info.t or 0.25, style,
dir), info.g)
end local function ApplyThemeGradient(parent, rot)
local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
ColorSequenceKeypoint.new(0.483, Color3.fromRGB(0, 170, 255)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
}
if rot then grad.Rotation = rot end
grad.Parent = parent
return grad
end
local function lak(a)
local Dragging = false
local DragInput = nil
local DragStart = nil
local StartPosition = nil
local function Update(input)
local Delta = input.Position - DragStart
local pos = UDim2.new(
StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
)
tw({v = a, t = 0.14, s = "Quart", d = "Out", g = {Position =
pos}}):Play()
end
TrackConn(a.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or
input.UserInputType == Enum.UserInputType.Touch then
Dragging = true
DragStart = input.Position
StartPosition = a.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
Dragging = false
end
end)
end
end))
TrackConn(a.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or
input.UserInputType == Enum.UserInputType.Touch then
DragInput = input
end
end)) TrackConn(UserInputService.InputChanged:Connect(function(input)
if input == DragInput and Dragging then
Update(input)
end
end))
end
local function click(p)
local Click = Instance.new("TextButton")
Click.Name = RandomName()
Click.Parent = p
Click.BackgroundTransparency = 1
Click.BorderSizePixel = 0
Click.Size = UDim2.new(1, 0, 1, 0)
Click.Font = Enum.Font.SourceSans
Click.Text = ""
Click.AutoButtonColor = false
return Click
end
local function AddHoverEffect(frame, defaultTrans)
defaultTrans = defaultTrans or 0.5
TrackConn(frame.MouseEnter:Connect(function()
tw({v = frame, t = 0.2, s = "Quart", d = "Out", g =
{BackgroundTransparency = math.clamp(defaultTrans - 0.15, 0, 1)}}):Play()
end))
TrackConn(frame.MouseLeave:Connect(function()
tw({v = frame, t = 0.2, s = "Quart", d = "Out", g =
{BackgroundTransparency = defaultTrans}}):Play()
end))
end
local function EffectClick(c, p, useGradient)
local relativeX = Mouse.X - c.AbsolutePosition.X
local relativeY = Mouse.Y - c.AbsolutePosition.Y
if relativeX < 0 or relativeY < 0 or relativeX > c.AbsoluteSize.X or
relativeY > c.AbsoluteSize.Y then return end
local Circle = Instance.new("Frame")
Circle.Name = RandomName()
Circle.Parent = p
Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Circle.BackgroundTransparency = 0.55
Circle.BorderSizePixel = 0
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.Position = UDim2.new(0, relativeX, 0, relativeY)
Circle.Size = UDim2.new(0, 0, 0, 0) Circle.ZIndex = 10
if useGradient then ApplyThemeGradient(Circle, 48) end
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = Circle
local expandTween = tw({
v = Circle,
t = 0.65,
s = "Quart",
d = "Out",
g = {
Size = UDim2.new(0, c.AbsoluteSize.X * 1.6, 0,
c.AbsoluteSize.X * 1.6),
BackgroundTransparency = 1
}
})
expandTween.Completed:Connect(function() Circle:Destroy() end)
expandTween:Play()
end
if getgenv and getgenv()._SyzenCleanup then
pcall(getgenv()._SyzenCleanup)
end
local Khaw = Instance.new("ScreenGui")
Khaw.Name = RandomName()
Khaw.Parent = GetSafeGuiParent()
Khaw.ZIndexBehavior = Enum.ZIndexBehavior.Global
Khaw.ResetOnSpawn = false
if getgenv then
getgenv()._SyzenCleanup = function()
for _, c in ipairs(Env.Connections) do pcall(function()
c:Disconnect() end) end
table.clear(Env.Connections)
if Khaw then pcall(function() Khaw:Destroy() end) end
end
end
function Env:Window(meta)
meta = meta.Config and meta or meta
local Title = meta.Title or "SyzenHub"
local Desc = meta.Desc or "Advanced Hub"
local ToggleKey = meta.Bind or meta.ToggleKey or Enum.KeyCode.F2 Persistent Config Setup
local ConfigName = meta.Config or "SyzenHub_Config"
local ConfigFolder = "SyzenHub"
local ConfigPath = ConfigFolder .. "/" .. ConfigName .. ".json"
local SavedConfig = {}
if writefile and readfile and isfolder and makefolder then
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
if isfile(ConfigPath) then
pcall(function()
SavedConfig =
HttpService:JSONDecode(readfile(ConfigPath))
end)
end
end
local function SaveConfig(key, val)
SavedConfig[key] = val
if writefile then
pcall(function()
writefile(ConfigPath,
HttpService:JSONEncode(SavedConfig))
end)
end
end
local Background_1 = Instance.new("Frame")
local DropShadow_1 = Instance.new("ImageLabel")
local UICorner_1 = Instance.new("UICorner")
local Header_1 = Instance.new("Frame")
local Title_1 = Instance.new("TextLabel")
local UIListLayout_1 = Instance.new("UIListLayout")
local UIPadding_1 = Instance.new("UIPadding")
local Line_1 = Instance.new("Frame")
local Desc_1 = Instance.new("TextLabel")
local Effect_1 = Instance.new("ImageLabel")
Background_1.Name = RandomName()
Background_1.Parent = Khaw
Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
Background_1.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Background_1.BackgroundTransparency = 0.35
Background_1.BorderSizePixel = 0
Background_1.Position = UDim2.new(0.5, 0, 0.5, 0)
Background_1.Size = UDim2.new(0, 0, 0, 0)
lak(Background_1) tw({v = Background_1, t = 0.55, s = "Back", d = "Out", g = {Size =
UDim2.new(0, 574, 0, 365)}}):Play()
DropShadow_1.Name = RandomName()
DropShadow_1.Parent = Background_1
DropShadow_1.AnchorPoint = Vector2.new(0.5, 0.5)
DropShadow_1.BackgroundTransparency = 1
DropShadow_1.Position = UDim2.new(0.5, 0, 0.5, 0)
DropShadow_1.Size = UDim2.new(1, 120, 1, 120)
DropShadow_1.ZIndex = 0
DropShadow_1.Image = "rbxassetid://8992230677"
DropShadow_1.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow_1.ImageTransparency = 0.3
DropShadow_1.ScaleType = Enum.ScaleType.Slice
DropShadow_1.SliceCenter = Rect.new(99, 99, 99, 99)
Effect_1.Name = RandomName()
Effect_1.Parent = Background_1
Effect_1.AnchorPoint = Vector2.new(0.5, 0.5)
Effect_1.BackgroundTransparency = 1
Effect_1.Position = UDim2.new(0.5, 0, 0.5, 0)
Effect_1.Size = UDim2.new(1, 0, 1, 0)
Effect_1.Image = "rbxassetid://132687652275989"
Effect_1.ImageColor3 = Color3.fromRGB(0, 255, 127)
Effect_1.ImageTransparency = 0.15
Effect_1.ScaleType = Enum.ScaleType.Crop
UICorner_1.Parent = Background_1
UICorner_1.CornerRadius = UDim.new(0, 18)
Header_1.Name = RandomName()
Header_1.Parent = Background_1
Header_1.BackgroundTransparency = 1
Header_1.Size = UDim2.new(1, 0, 0, 73)
Title_1.Name = RandomName()
Title_1.Parent = Header_1
Title_1.BackgroundTransparency = 1
Title_1.Position = UDim2.new(0, 0, 0.116, 0)
Title_1.Size = UDim2.new(0, 462, 0, 22)
Title_1.Font = Enum.Font.GothamBold
Title_1.Text = Title
Title_1.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_1.TextSize = 24
Title_1.TextWrapped = true
Title_1.TextXAlignment = Enum.TextXAlignment.Left
UIListLayout_1.Parent = Header_1 UIListLayout_1.Padding = UDim.new(0, 7)
UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center
UIPadding_1.Parent = Header_1
UIPadding_1.PaddingLeft = UDim.new(0, 20)
UIPadding_1.PaddingTop = UDim.new(0, 3)
Line_1.Name = RandomName()
Line_1.Parent = Header_1
Line_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Line_1.BorderSizePixel = 0
Line_1.Size = UDim2.new(0, 70, 0, 2)
ApplyThemeGradient(Line_1)
Desc_1.Name = RandomName()
Desc_1.Parent = Header_1
Desc_1.BackgroundTransparency = 1
Desc_1.Size = UDim2.new(0, 350, 0, 14)
Desc_1.Font = Enum.Font.GothamBold
Desc_1.Text = Desc
Desc_1.TextColor3 = Color3.fromRGB(255, 255, 255)
Desc_1.TextSize = 14
Desc_1.TextTransparency = 0.45
Desc_1.TextXAlignment = Enum.TextXAlignment.Left
-- Notification Holder Container
local NotifHolder = Instance.new("Frame")
NotifHolder.Name = RandomName()
NotifHolder.Parent = Khaw
NotifHolder.AnchorPoint = Vector2.new(1, 1)
NotifHolder.Position = UDim2.new(1, -20, 1, -20)
NotifHolder.Size = UDim2.new(0, 300, 1, 0)
NotifHolder.BackgroundTransparency = 1
local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Parent = NotifHolder
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
-- Floating Toggle Button (Full Box Logo Asset: 139585880965481)
local CloseUI = Instance.new("ImageButton")
CloseUI.Name = RandomName()
CloseUI.Parent = Khaw
CloseUI.AnchorPoint = Vector2.new(0, 1)
CloseUI.BackgroundColor3 = Color3.fromRGB(255, 255, 255) CloseUI.BackgroundTransparency = 1
CloseUI.BorderSizePixel = 0
CloseUI.Position = UDim2.new(0.05, 0, 0.22, 0)
CloseUI.Size = UDim2.new(0, 50, 0, 50)
CloseUI.Image = "rbxassetid://139585880965481"
CloseUI.ScaleType = Enum.ScaleType.Crop
CloseUI.AutoButtonColor = false
lak(CloseUI)
-- Platform Detection: Show if Mobile/Tablet, Hide if PC
local isMobileUser = (UserInputService.TouchEnabled and not
UserInputService.KeyboardEnabled) or RunService:IsStudio()
CloseUI.Visible = isMobileUser
local isUiOpen = true
local function closeopenui()
isUiOpen = not isUiOpen
task.spawn(function()
tw({v = CloseUI, t = 0.14, s = "Quart", d = "Out", g = {Size =
UDim2.new(0, 40, 0, 40)}}):Play()
task.wait(0.14)
tw({v = CloseUI, t = 0.22, s = "Back", d = "Out", g = {Size =
UDim2.new(0, 50, 0, 50)}}):Play()
end)
if isUiOpen then
Background_1.Visible = true
tw({v = Background_1, t = 0.4, s = "Back", d = "Out", g =
{Size = UDim2.new(0, 574, 0, 365)}}):Play()
else
local hideTween = tw({v = Background_1, t = 0.25, s = "Quart",
d = "In", g = {Size = UDim2.new(0, 0, 0, 0)}})
hideTween.Completed:Connect(function()
if not isUiOpen then Background_1.Visible = false end
end)
hideTween:Play()
end
end
TrackConn(CloseUI.MouseButton1Click:Connect(closeopenui))
TrackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
if not gameProcessed and input.KeyCode == ToggleKey then
closeopenui()
end
end))
local WindowObj = {} function WindowObj:Notify(notifMeta)
notifMeta = notifMeta or {}
local NTitle = notifMeta.Title or "SyzenHub"
local NDesc = notifMeta.Desc or notifMeta.Content or "Notification
message"
local NTime = notifMeta.Duration or 3.5
local Card = Instance.new("Frame")
local UICorner_N = Instance.new("UICorner")
local UIStroke_N = Instance.new("UIStroke")
local Title_N = Instance.new("TextLabel")
local Desc_N = Instance.new("TextLabel")
local Bar = Instance.new("Frame")
Card.Name = RandomName()
Card.Parent = NotifHolder
Card.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Card.BackgroundTransparency = 0.15
Card.BorderSizePixel = 0
Card.Size = UDim2.new(0, 0, 0, 0)
Card.ClipsDescendants = true
UICorner_N.Parent = Card
UICorner_N.CornerRadius = UDim.new(0, 8)
UIStroke_N.Parent = Card
UIStroke_N.Color = Color3.fromRGB(255, 255, 255)
UIStroke_N.Transparency = 0.7
ApplyThemeGradient(UIStroke_N)
Title_N.Parent = Card
Title_N.BackgroundTransparency = 1
Title_N.Position = UDim2.new(0, 14, 0, 10)
Title_N.Size = UDim2.new(1, -28, 0, 18)
Title_N.Font = Enum.Font.GothamBold
Title_N.Text = NTitle
Title_N.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_N.TextSize = 13
Title_N.TextXAlignment = Enum.TextXAlignment.Left
Desc_N.Parent = Card
Desc_N.BackgroundTransparency = 1
Desc_N.Position = UDim2.new(0, 14, 0, 30)
Desc_N.Size = UDim2.new(1, -28, 0, 30)
Desc_N.Font = Enum.Font.GothamMedium
Desc_N.Text = NDesc
Desc_N.TextColor3 = Color3.fromRGB(200, 200, 215) Desc_N.TextSize = 11
Desc_N.TextWrapped = true
Desc_N.TextXAlignment = Enum.TextXAlignment.Left
Desc_N.TextYAlignment = Enum.TextYAlignment.Top
Bar.Parent = Card
Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Bar.BorderSizePixel = 0
Bar.Position = UDim2.new(0, 0, 1, -3)
Bar.Size = UDim2.new(1, 0, 0, 3)
ApplyThemeGradient(Bar)
tw({v = Card, t = 0.35, s = "Back", d = "Out", g = {Size =
UDim2.new(0, 260, 0, 72)}}):Play()
task.delay(NTime, function()
local outTween = tw({v = Card, t = 0.25, s = "Quart", d =
"In", g = {Size = UDim2.new(0, 260, 0, 0)}})
outTween.Completed:Connect(function() Card:Destroy() end)
outTween:Play()
end)
end
local Tab_1 = Instance.new("Frame")
local ScrollingFrame_1 = Instance.new("ScrollingFrame")
local UIListLayout_2 = Instance.new("UIListLayout")
Tab_1.Name = RandomName()
Tab_1.Parent = Background_1
Tab_1.AnchorPoint = Vector2.new(0.5, 0.5)
Tab_1.BackgroundTransparency = 1
Tab_1.Position = UDim2.new(0.5, 0, 0.6, 0)
Tab_1.Size = UDim2.new(1, 0, 0.8, 0)
ScrollingFrame_1.Name = RandomName()
ScrollingFrame_1.Parent = Tab_1
ScrollingFrame_1.Active = true
ScrollingFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
ScrollingFrame_1.BackgroundTransparency = 1
ScrollingFrame_1.BorderSizePixel = 0
ScrollingFrame_1.Position = UDim2.new(0.5, 0, 0.474, 0)
ScrollingFrame_1.Size = UDim2.new(0.95, 0, 0.96, 0)
ScrollingFrame_1.ClipsDescendants = true
ScrollingFrame_1.CanvasSize = UDim2.new(0, 20, 0, 0)
ScrollingFrame_1.ScrollBarThickness = 0
ScrollingFrame_1.ScrollingDirection = Enum.ScrollingDirection.X
UIListLayout_2.Parent = ScrollingFrame_1 UIListLayout_2.Padding = UDim.new(0, 10)
UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
TrackConn(UIListLayout_2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(f
unction()
ScrollingFrame_1.CanvasSize = UDim2.new(0,
UIListLayout_2.AbsoluteContentSize.X + 20, 0, 0)
end))
local Return = Instance.new("Frame")
local UICorner_Ret = Instance.new("UICorner")
local UIGradient_Ret = Instance.new("UIGradient")
local UIStroke_1z = Instance.new("UIStroke")
local ImageLabel_1z = Instance.new("ImageLabel")
local TextLabel_1z = Instance.new("TextLabel")
Return.Name = RandomName()
Return.Parent = Background_1
Return.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Return.BorderSizePixel = 0
Return.Position = UDim2.new(0.77, 0, 0.049, 0)
Return.Size = UDim2.new(0, 110, 0, 29)
Return.ClipsDescendants = true
Return.Visible = false
UICorner_Ret.Parent = Return
UICorner_Ret.CornerRadius = UDim.new(0, 6)
UIGradient_Ret.Parent = Return
UIGradient_Ret.Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 89, 89)),
ColorSequenceKeypoint.new(0.483, Color3.fromRGB(255, 0, 0)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 0, 0))
}
UIStroke_1z.Parent = Return
UIStroke_1z.Color = Color3.fromRGB(255, 85, 127)
UIStroke_1z.Thickness = 1.5
ImageLabel_1z.Name = RandomName()
ImageLabel_1z.Parent = Return
ImageLabel_1z.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel_1z.BackgroundTransparency = 1
ImageLabel_1z.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel_1z.Size = UDim2.new(1, 50, 1, 0)
ImageLabel_1z.Image = "rbxassetid://87782680483863" ImageLabel_1z.ImageTransparency = 0.84
ImageLabel_1z.ScaleType = Enum.ScaleType.Crop
TextLabel_1z.Name = RandomName()
TextLabel_1z.Parent = Return
TextLabel_1z.AnchorPoint = Vector2.new(0.5, 0.5)
TextLabel_1z.BackgroundTransparency = 1
TextLabel_1z.Position = UDim2.new(0.5, 0, 0.5, 0)
TextLabel_1z.Size = UDim2.new(1, 0, 1, 0)
TextLabel_1z.Font = Enum.Font.GothamBold
TextLabel_1z.Text = "Back"
TextLabel_1z.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_1z.TextSize = 14
local ClickReturn = click(Return)
TrackConn(ClickReturn.MouseButton1Click:Connect(function()
Header_1.Position = UDim2.new(0, -30, 0, 0)
tw({v = Header_1, t = 0.3, s = "Back", d = "Out", g = {Position =
UDim2.new(0, 0, 0, 0)}}):Play()
tw({v = Title_1, t = 0.2, s = "Quart", d = "Out", g =
{TextTransparency = 1}}):Play()
tw({v = Desc_1, t = 0.2, s = "Quart", d = "Out", g =
{TextTransparency = 1}}):Play()
tw({v = Line_1, t = 0.2, s = "Quart", d = "Out", g =
{BackgroundTransparency = 1}}):Play()
Desc_1.Text = Desc
Title_1.Text = Title
task.delay(0.15, function()
tw({v = Title_1, t = 0.35, s = "Back", d = "Out", g =
{TextTransparency = 0}}):Play()
tw({v = Desc_1, t = 0.35, s = "Back", d = "Out", g =
{TextTransparency = 0.45}}):Play()
tw({v = Line_1, t = 0.35, s = "Back", d = "Out", g =
{BackgroundTransparency = 0}}):Play()
end)
for _, pageFrame in ipairs(Env.PagesList) do pageFrame.Visible =
false end
Tab_1.Visible = true
Tab_1.Size = UDim2.new(1, 0, 0, 0)
tw({v = Tab_1, t = 0.35, s = "Back", d = "Out", g = {Size =
UDim2.new(1, 0, 0.8, 0)}}):Play()
tw({v = Return, t = 0.25, s = "Quart", d = "Out", g = {Position =
UDim2.new(0.9, 0, 0.049, 0), BackgroundTransparency = 1}}):Play() UIStroke_1z.Enabled = false
tw({v = ImageLabel_1z, t = 0.25, s = "Quart", d = "Out", g =
{ImageTransparency = 1}}):Play()
tw({v = TextLabel_1z, t = 0.25, s = "Quart", d = "Out", g =
{TextTransparency = 1}}):Play()
task.wait(0.2)
Return.Visible = false
end))
local TabsObj = {}
function TabsObj:Add(tabMeta)
tabMeta = tabMeta or {}
local TabTitle = tabMeta.Title or "Tab"
local TabDesc = tabMeta.Desc or ""
local Banner = tabMeta.Banner or "general"
local Addtab_1 = Instance.new("Frame")
local Banner_1 = Instance.new("ImageLabel")
local UICorner_2 = Instance.new("UICorner")
local ClickTab = click(Addtab_1)
Addtab_1.Name = RandomName()
Addtab_1.Parent = ScrollingFrame_1
Addtab_1.BackgroundTransparency = 1
Addtab_1.Size = UDim2.new(0, 100, 1, 0)
Banner_1.Name = RandomName()
Banner_1.Parent = Addtab_1
Banner_1.AnchorPoint = Vector2.new(0.5, 0.5)
Banner_1.Position = UDim2.new(0.5, 0, 0.5, 0)
Banner_1.Size = UDim2.new(1, 0, 1, 0)
Banner_1.BackgroundTransparency = 1
Banner_1.Image = GetIcon(Banner)
UICorner_2.Parent = Banner_1
UICorner_2.CornerRadius = UDim.new(0, 10)
TrackConn(ClickTab.MouseEnter:Connect(function()
tw({v = Banner_1, t = 0.2, s = "Back", d = "Out", g = {Size =
UDim2.new(1, 6, 1, -6)}}):Play()
end))
TrackConn(ClickTab.MouseLeave:Connect(function()
tw({v = Banner_1, t = 0.2, s = "Quart", d = "Out", g = {Size =
UDim2.new(1, 0, 1, 0)}}):Play()
end))
local Pages_1 = Instance.new("Frame") local UIListLayout_5 = Instance.new("UIListLayout")
Pages_1.Name = RandomName()
Pages_1.Parent = Background_1
Pages_1.AnchorPoint = Vector2.new(0.5, 0.5)
Pages_1.BackgroundTransparency = 1
Pages_1.Position = UDim2.new(0.5, 0, 0.588, 0)
Pages_1.Size = UDim2.new(0.965, 0, 0.767, 0)
Pages_1.Visible = false
table.insert(Env.PagesList, Pages_1)
UIListLayout_5.Parent = Pages_1
UIListLayout_5.Padding = UDim.new(0, 6)
UIListLayout_5.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_5.VerticalAlignment = Enum.VerticalAlignment.Center
local Left_1 = Instance.new("ScrollingFrame")
local UIListLayout_3 = Instance.new("UIListLayout")
Left_1.Name = RandomName()
Left_1.Parent = Pages_1
Left_1.Active = true
Left_1.BackgroundTransparency = 1
Left_1.BorderSizePixel = 0
Left_1.Size = UDim2.new(0, 275, 1, 0)
Left_1.ClipsDescendants = true
Left_1.ScrollBarThickness = 0
Left_1.ScrollingDirection = Enum.ScrollingDirection.Y
UIListLayout_3.Parent = Left_1
UIListLayout_3.Padding = UDim.new(0, 7)
UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
local Right_1 = Instance.new("ScrollingFrame")
local UIListLayout_6 = Instance.new("UIListLayout")
Right_1.Name = RandomName()
Right_1.Parent = Pages_1
Right_1.Active = true
Right_1.BackgroundTransparency = 1
Right_1.BorderSizePixel = 0
Right_1.Size = UDim2.new(0, 275, 1, 0)
Right_1.ClipsDescendants = true
Right_1.ScrollBarThickness = 0
Right_1.ScrollingDirection = Enum.ScrollingDirection.Y
UIListLayout_6.Parent = Right_1 UIListLayout_6.Padding = UDim.new(0, 7)
UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder
TrackConn(UIListLayout_3:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(f
unction()
Left_1.CanvasSize = UDim2.new(0, 0, 0,
UIListLayout_3.AbsoluteContentSize.Y + 20)
end))
TrackConn(UIListLayout_6:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(f
unction()
Right_1.CanvasSize = UDim2.new(0, 0, 0,
UIListLayout_6.AbsoluteContentSize.Y + 20)
end))
TrackConn(ClickTab.MouseButton1Click:Connect(function()
Header_1.Position = UDim2.new(0, -30, 0, 0)
tw({v = Header_1, t = 0.3, s = "Back", d = "Out", g =
{Position = UDim2.new(0, 0, 0, 0)}}):Play()
tw({v = Title_1, t = 0.2, s = "Quart", d = "Out", g =
{TextTransparency = 1}}):Play()
tw({v = Desc_1, t = 0.2, s = "Quart", d = "Out", g =
{TextTransparency = 1}}):Play()
tw({v = Line_1, t = 0.2, s = "Quart", d = "Out", g =
{BackgroundTransparency = 1}}):Play()
Desc_1.Text = TabDesc
Title_1.Text = TabTitle
task.delay(0.15, function()
tw({v = Title_1, t = 0.35, s = "Back", d = "Out", g =
{TextTransparency = 0}}):Play()
tw({v = Desc_1, t = 0.35, s = "Back", d = "Out", g =
{TextTransparency = 0.45}}):Play()
tw({v = Line_1, t = 0.35, s = "Back", d = "Out", g =
{BackgroundTransparency = 0}}):Play()
end)
Return.Visible = true
UIStroke_1z.Enabled = true
Return.Position = UDim2.new(0.9, 0, 0.049, 0)
tw({v = Return, t = 0.3, s = "Back", d = "Out", g = {Position
= UDim2.new(0.77, 0, 0.049, 0), BackgroundTransparency = 0}}):Play()
tw({v = UIStroke_1z, t = 0.3, s = "Back", d = "Out", g =
{Transparency = 0}}):Play()
tw({v = ImageLabel_1z, t = 0.3, s = "Back", d = "Out", g =
{ImageTransparency = 0.84}}):Play() tw({v = TextLabel_1z, t = 0.3, s = "Back", d = "Out", g =
{TextTransparency = 0}}):Play()
Tab_1.Visible = false
for _, p in ipairs(Env.PagesList) do p.Visible = false end
Pages_1.Size = UDim2.new(0.965, 0, 0, 0)
Pages_1.Visible = true
tw({v = Pages_1, t = 0.3, s = "Back", d = "Out", g = {Size =
UDim2.new(0.965, 0, 0.767, 0)}}):Play()
end))
local function GetSide(side)
if not side then return Left_1 end
local sideLower = string.lower(tostring(side))
if sideLower == "r" or sideLower == "right" or side == 2 then
return Right_1
end
return Left_1
end
local SectionBuilder = {}
function SectionBuilder:Section(secMeta)
secMeta = secMeta or {}
local SecTitle = secMeta.Title or "Section"
local Side = secMeta.Side or "l"
local Section_1 = Instance.new("Frame")
local UICorner_3 = Instance.new("UICorner")
local UIListLayout_4 = Instance.new("UIListLayout")
local Title_2 = Instance.new("TextLabel")
local UIPadding_2 = Instance.new("UIPadding")
local Line_2 = Instance.new("Frame")
Section_1.Name = RandomName()
Section_1.Parent = GetSide(Side)
Section_1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Section_1.BackgroundTransparency = 0.55
Section_1.BorderSizePixel = 0
Section_1.Size = UDim2.new(1, 0, 0, 100)
UICorner_3.Parent = Section_1
UICorner_3.CornerRadius = UDim.new(0, 6)
UIListLayout_4.Parent = Section_1
UIListLayout_4.Padding = UDim.new(0, 6)
UIListLayout_4.HorizontalAlignment =
Enum.HorizontalAlignment.Center UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder
Title_2.Name = RandomName()
Title_2.Parent = Section_1
Title_2.BackgroundTransparency = 1
Title_2.LayoutOrder = -3
Title_2.Size = UDim2.new(0.9, 0, 0, 20)
Title_2.Font = Enum.Font.GothamBold
Title_2.Text = SecTitle
Title_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_2.TextSize = 15
UIPadding_2.Parent = Section_1
UIPadding_2.PaddingTop = UDim.new(0, 7)
Line_2.Name = RandomName()
Line_2.Parent = Section_1
Line_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Line_2.BorderSizePixel = 0
Line_2.BackgroundTransparency = 0.25
Line_2.LayoutOrder = -2
Line_2.Size = UDim2.new(1, 0, 0, 1)
ApplyThemeGradient(Line_2)
TrackConn(UIListLayout_4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(f
unction()
Section_1.Size = UDim2.new(1, 0, 0,
UIListLayout_4.AbsoluteContentSize.Y + 15)
end))
local ClassObj = {}
function ClassObj:Button(btnMeta)
btnMeta = btnMeta or {}
local BTitle = btnMeta.Title or "Button"
local BDesc = btnMeta.Desc or nil
local Callback = btnMeta.Callback or function() end
local BIcon = btnMeta.Icon or nil
if not BIcon and not BDesc then
local Button = Instance.new("Frame")
local Title_B = Instance.new("TextLabel")
local UICorner_B = Instance.new("UICorner")
local ImageLabel_B = Instance.new("ImageLabel")
local Clickbutton = click(Button)
Button.Name = RandomName() Button.Parent = Section_1
Button.AnchorPoint = Vector2.new(0.5, 0.5)
Button.BackgroundColor3 = Color3.fromRGB(255,
255, 255)
Button.BorderSizePixel = 0
Button.Size = UDim2.new(0.97, 0, 0, 32)
Button.ClipsDescendants = true
ApplyThemeGradient(Button)
Title_B.Name = RandomName()
Title_B.Parent = Button
Title_B.AnchorPoint = Vector2.new(0.5, 0.5)
Title_B.BackgroundTransparency = 1
Title_B.Position = UDim2.new(0.5, 0, 0.5, 0)
Title_B.Size = UDim2.new(1, 0, 1, 0)
Title_B.Font = Enum.Font.GothamBold
Title_B.Text = BTitle
Title_B.TextColor3 = Color3.fromRGB(255, 255,
255)
Title_B.TextSize = 14
UICorner_B.Parent = Button
UICorner_B.CornerRadius = UDim.new(0, 6)
ImageLabel_B.Name = RandomName()
ImageLabel_B.Parent = Button
ImageLabel_B.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel_B.BackgroundTransparency = 1
ImageLabel_B.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel_B.Size = UDim2.new(1, 50, 1, 0)
ImageLabel_B.Image =
"rbxassetid://72380279434385"
ImageLabel_B.ImageTransparency = 0.8
ImageLabel_B.ScaleType = Enum.ScaleType.Crop
TrackConn(Clickbutton.MouseButton1Click:Connect(function()
task.spawn(Callback)
tw({v = Button, t = 0.12, s = "Quart", d =
"Out", g = {Size = UDim2.new(0.91, 0, 0, 30)}}):Play()
task.delay(0.1, function()
tw({v = Button, t = 0.2, s = "Back",
d = "Out", g = {Size = UDim2.new(0.97, 0, 0, 32)}}):Play()
end)
EffectClick(Clickbutton, Button, false)
end))
local Index = {} function Index:Fire() task.spawn(Callback) end
function Index:Title(v) Title_B.Text =
tostring(v) end
function Index:Visible(v) Button.Visible = v end
return Index
else
local ButtonImage = Instance.new("Frame")
local Title_B = Instance.new("TextLabel")
local UICorner_B = Instance.new("UICorner")
local ImageLabel_B = Instance.new("ImageLabel")
local icon_1 = Instance.new("ImageLabel")
local Desc_B = Instance.new("TextLabel")
local next_1 = Instance.new("ImageLabel")
local ClickButton = click(ButtonImage)
ButtonImage.Name = RandomName()
ButtonImage.Parent = Section_1
ButtonImage.AnchorPoint = Vector2.new(0.5, 0.5)
ButtonImage.BackgroundColor3 = Color3.fromRGB(0,
0, 0)
ButtonImage.BackgroundTransparency = 0.5
ButtonImage.BorderSizePixel = 0
ButtonImage.Size = UDim2.new(0.97, 0, 0, 50)
ButtonImage.ClipsDescendants = true
AddHoverEffect(ButtonImage, 0.5)
Title_B.Name = RandomName()
Title_B.Parent = ButtonImage
Title_B.AnchorPoint = Vector2.new(0.5, 0.5)
Title_B.BackgroundTransparency = 1
Title_B.Position = UDim2.new(0.576, 0, 0.368, 0)
Title_B.Size = UDim2.new(0.776, 0, 0.07, 20)
Title_B.Font = Enum.Font.GothamBold
Title_B.RichText = true
Title_B.Text = BTitle
Title_B.TextColor3 = Color3.fromRGB(255, 255,
255)
Title_B.TextSize = 14
Title_B.TextXAlignment = Enum.TextXAlignment.Left
UICorner_B.Parent = ButtonImage
UICorner_B.CornerRadius = UDim.new(0, 6)
ImageLabel_B.Name = RandomName()
ImageLabel_B.Parent = ButtonImage
ImageLabel_B.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel_B.BackgroundTransparency = 1
ImageLabel_B.Position = UDim2.new(0.5, 0, 0.5, 0) ImageLabel_B.Size = UDim2.new(1, 50, 1, 0)
ImageLabel_B.Image =
"rbxassetid://72380279434385"
ImageLabel_B.ImageTransparency = 0.9
ImageLabel_B.ScaleType = Enum.ScaleType.Crop
ApplyThemeGradient(ImageLabel_B)
icon_1.Name = RandomName()
icon_1.Parent = ButtonImage
icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
icon_1.BackgroundTransparency = 1
icon_1.Position = UDim2.new(0, 25, 0.5, 0)
icon_1.Size = UDim2.new(0, 32, 0, 32)
icon_1.Image = GetIcon(BIcon or "sparkles")
icon_1.ScaleType = Enum.ScaleType.Fit
Desc_B.Name = RandomName()
Desc_B.Parent = ButtonImage
Desc_B.AnchorPoint = Vector2.new(0.5, 0.5)
Desc_B.BackgroundTransparency = 1
Desc_B.Position = UDim2.new(0.576, 0, 0.665, 0)
Desc_B.Size = UDim2.new(0.776, 0, -0.036, 20)
Desc_B.Font = Enum.Font.GothamBold
Desc_B.RichText = true
Desc_B.Text = BDesc or ""
Desc_B.TextColor3 = Color3.fromRGB(255, 255, 255)
Desc_B.TextSize = 10
Desc_B.TextTransparency = 0.5
Desc_B.TextXAlignment = Enum.TextXAlignment.Left
next_1.Name = RandomName()
next_1.Parent = ButtonImage
next_1.AnchorPoint = Vector2.new(0.5, 0.5)
next_1.BackgroundTransparency = 1
next_1.Position = UDim2.new(0, 245, 0.5, 0)
next_1.Size = UDim2.new(0, 20, 0, 20)
next_1.Image = GetIcon("arrow_right")
next_1.ScaleType = Enum.ScaleType.Fit
TrackConn(ClickButton.MouseButton1Click:Connect(function()
task.spawn(Callback)
tw({v = next_1, t = 0.14, s = "Back", d =
"Out", g = {Position = UDim2.new(0, 253, 0.5, 0)}}):Play()
task.delay(0.1, function()
tw({v = next_1, t = 0.18, s =
"Back", d = "Out", g = {Position = UDim2.new(0, 245, 0.5, 0)}}):Play()
end) EffectClick(ClickButton, ButtonImage,
true)
end))
local Index = {}
function Index:Fire() task.spawn(Callback) end
function Index:Title(v) Title_B.Text =
tostring(v) end
function Index:Desc(v) Desc_B.Text = tostring(v)
end
function Index:Visible(v) ButtonImage.Visible = v
end
return Index
end
end
function ClassObj:ThumnailsImage(imgMeta)
imgMeta = imgMeta or {}
local Banner = imgMeta.Banner
local Y = imgMeta.SizeY or 150
local Image = Instance.new("ImageLabel")
Image.Name = RandomName()
Image.Parent = Section_1
Image.BackgroundTransparency = 1
Image.BorderSizePixel = 0
Image.Size = UDim2.new(0.97, 0, 0, Y)
Image.Image = GetIcon(Banner)
Image.ScaleType = Enum.ScaleType.Crop
local UICorner_I = Instance.new("UICorner")
UICorner_I.Parent = Image
UICorner_I.CornerRadius = UDim.new(0, 6)
local Index = {}
function Index:Image(v) Image.Image = GetIcon(v) end
function Index:Visible(v) Image.Visible = v end
return Index
end
local function GetAlig(v)
if v == "l" then return Enum.TextXAlignment.Left
elseif v == "r" then return Enum.TextXAlignment.Right
else return Enum.TextXAlignment.Center end
end
function ClassObj:Label(lblMeta) lblMeta = type(lblMeta) == "table" and lblMeta or {Title
= tostring(lblMeta), Side = "l"}
local LTitle = lblMeta.Title or "Label"
local LSide = lblMeta.Side
local Label = Instance.new("TextLabel")
Label.Name = RandomName()
Label.Parent = Section_1
Label.BackgroundTransparency = 1
Label.Size = UDim2.new(0.9, 0, 0, 20)
Label.Font = Enum.Font.GothamBold
Label.RichText = true
Label.Text = LTitle
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.TextSize = 14
Label.TextXAlignment = GetAlig(LSide)
local Index = {}
function Index:Title(v) Label.Text = tostring(v) end
function Index:Set(v) Label.Text = tostring(v) end
function Index:Visible(v) Label.Visible = v end
return Index
end
function ClassObj:Line()
local Line_Sub = Instance.new("Frame")
Line_Sub.Name = RandomName()
Line_Sub.Parent = Section_1
Line_Sub.BackgroundColor3 = Color3.fromRGB(255, 255,
255)
Line_Sub.BorderSizePixel = 0
Line_Sub.BackgroundTransparency = 0.25
Line_Sub.Size = UDim2.new(1, 0, 0, 1)
ApplyThemeGradient(Line_Sub)
local Index = {}
function Index:Visible(v) Line_Sub.Visible = v end
return Index
end
function ClassObj:Discord(Link)
local Discord = Instance.new("Frame")
local Title_D = Instance.new("TextLabel")
local UICorner_D = Instance.new("UICorner")
local ImageLabel_D = Instance.new("ImageLabel")
local UIGradient_D = Instance.new("UIGradient")
local icon_D = Instance.new("ImageLabel")
local Desc_D = Instance.new("TextLabel") local ClickDiscord = click(Discord)
Discord.Name = RandomName()
Discord.Parent = Section_1
Discord.AnchorPoint = Vector2.new(0.5, 0.5)
Discord.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Discord.BorderSizePixel = 0
Discord.Size = UDim2.new(0.97, 0, 0, 60)
Discord.ClipsDescendants = true
Title_D.Name = RandomName()
Title_D.Parent = Discord
Title_D.AnchorPoint = Vector2.new(0.5, 0.5)
Title_D.BackgroundTransparency = 1
Title_D.Position = UDim2.new(0.611, 0, 0.408, 0)
Title_D.Size = UDim2.new(0.705, 0, 0.15, 20)
Title_D.Font = Enum.Font.GothamBold
Title_D.Text = "Discord"
Title_D.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_D.TextSize = 16
Title_D.TextXAlignment = Enum.TextXAlignment.Left
UICorner_D.Parent = Discord
UICorner_D.CornerRadius = UDim.new(0, 6)
ImageLabel_D.Name = RandomName()
ImageLabel_D.Parent = Discord
ImageLabel_D.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel_D.BackgroundTransparency = 1
ImageLabel_D.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel_D.Size = UDim2.new(1, 50, 1, 0)
ImageLabel_D.Image = "rbxassetid://72380279434385"
ImageLabel_D.ImageTransparency = 0.9
ImageLabel_D.ScaleType = Enum.ScaleType.Crop
UIGradient_D.Parent = Discord
UIGradient_D.Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(88,
101, 242)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(142,
130, 255))
}
icon_D.Name = RandomName()
icon_D.Parent = Discord
icon_D.AnchorPoint = Vector2.new(0.5, 0.5)
icon_D.BackgroundTransparency = 1
icon_D.Position = UDim2.new(0, 35, 0.5, 0) icon_D.Size = UDim2.new(0, 40, 0, 40)
icon_D.Image = GetIcon("discord")
icon_D.ScaleType = Enum.ScaleType.Crop
Desc_D.Name = RandomName()
Desc_D.Parent = Discord
Desc_D.AnchorPoint = Vector2.new(0.5, 0.5)
Desc_D.BackgroundTransparency = 1
Desc_D.Position = UDim2.new(0.611, 0, 0.675, 0)
Desc_D.Size = UDim2.new(0.705, 0, -0.016, 20)
Desc_D.Font = Enum.Font.GothamBold
Desc_D.Text = tostring(Link)
Desc_D.TextColor3 = Color3.fromRGB(255, 255, 255)
Desc_D.TextSize = 13
Desc_D.TextTransparency = 0.45
Desc_D.TextXAlignment = Enum.TextXAlignment.Left
TrackConn(ClickDiscord.MouseButton1Click:Connect(function()
if setclipboard then pcall(setclipboard,
tostring(Link)) end
EffectClick(ClickDiscord, Discord, false)
end))
end
function ClassObj:Toggle(togMeta)
togMeta = togMeta or {}
local TTitle = togMeta.Title or "Toggle"
local TDesc = togMeta.Desc or ""
local TIcon = togMeta.Icon or nil
local Flag = togMeta.Flag or TTitle
local DefaultVal = SavedConfig[Flag] ~= nil and
SavedConfig[Flag] or (togMeta.Value or false)
local Callback = togMeta.Callback or function() end
local ToggleFrame = Instance.new("Frame")
local Title_T = Instance.new("TextLabel")
local UICorner_T = Instance.new("UICorner")
local ImageLabel_T = Instance.new("ImageLabel")
local Desc_T = Instance.new("TextLabel")
local Check_1 = Instance.new("Frame")
local ColorFrame_1 = Instance.new("Frame")
local UICorner_2 = Instance.new("UICorner")
local ImageLabel_2 = Instance.new("ImageLabel")
local UICorner_3 = Instance.new("UICorner")
local ClickToggle = click(ToggleFrame)
ToggleFrame.Name = RandomName() ToggleFrame.Parent = Section_1
ToggleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleFrame.BackgroundTransparency = 0.5
ToggleFrame.BorderSizePixel = 0
ToggleFrame.Size = UDim2.new(0.97, 0, 0, 50)
ToggleFrame.ClipsDescendants = true
AddHoverEffect(ToggleFrame, 0.5)
local textPosX = TIcon and 0.576 or 0.5
local textSizeX = TIcon and 0.776 or 0.928
Title_T.Name = RandomName()
Title_T.Parent = ToggleFrame
Title_T.AnchorPoint = Vector2.new(0.5, 0.5)
Title_T.BackgroundTransparency = 1
Title_T.Position = UDim2.new(textPosX, 0, 0.368, 0)
Title_T.Size = UDim2.new(textSizeX, 0, 0.07, 20)
Title_T.Font = Enum.Font.GothamBold
Title_T.RichText = true
Title_T.Text = TTitle
Title_T.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_T.TextSize = 14
Title_T.TextXAlignment = Enum.TextXAlignment.Left
Title_T.TextTransparency = 0.5
UICorner_T.Parent = ToggleFrame
UICorner_T.CornerRadius = UDim.new(0, 6)
ImageLabel_T.Name = RandomName()
ImageLabel_T.Parent = ToggleFrame
ImageLabel_T.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel_T.BackgroundTransparency = 1
ImageLabel_T.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel_T.Size = UDim2.new(1, 50, 1, 0)
ImageLabel_T.Image = "rbxassetid://72380279434385"
ImageLabel_T.ImageTransparency = 0.9
ImageLabel_T.ScaleType = Enum.ScaleType.Crop
ApplyThemeGradient(ImageLabel_T)
local icon_1
if TIcon then
icon_1 = Instance.new("ImageLabel")
icon_1.Name = RandomName()
icon_1.Parent = ToggleFrame
icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
icon_1.BackgroundTransparency = 1
icon_1.Position = UDim2.new(0, 25, 0.5, 0) icon_1.Size = UDim2.new(0, 32, 0, 32)
icon_1.Image = GetIcon(TIcon)
icon_1.ScaleType = Enum.ScaleType.Fit
end
Desc_T.Name = RandomName()
Desc_T.Parent = ToggleFrame
Desc_T.AnchorPoint = Vector2.new(0.5, 0.5)
Desc_T.BackgroundTransparency = 1
Desc_T.Position = UDim2.new(textPosX, 0, 0.665, 0)
Desc_T.Size = UDim2.new(textSizeX, 0, -0.036, 20)
Desc_T.Font = Enum.Font.GothamBold
Desc_T.RichText = true
Desc_T.Text = TDesc
Desc_T.TextColor3 = Color3.fromRGB(255, 255, 255)
Desc_T.TextSize = 10
Desc_T.TextTransparency = 0.5
Desc_T.TextXAlignment = Enum.TextXAlignment.Left
Check_1.Name = RandomName()
Check_1.Parent = ToggleFrame
Check_1.AnchorPoint = Vector2.new(0.5, 0.5)
Check_1.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
Check_1.BorderSizePixel = 0
Check_1.Position = UDim2.new(0.9, 0, 0.5, 0)
Check_1.Size = UDim2.new(0, 25, 0, 25)
Check_1.ClipsDescendants = true
ColorFrame_1.Name = RandomName()
ColorFrame_1.Parent = Check_1
ColorFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
ColorFrame_1.BackgroundColor3 = Color3.fromRGB(255, 255,
255)
ColorFrame_1.BorderSizePixel = 0
ColorFrame_1.Position = UDim2.new(0.5, 0, 0.5, 0)
ColorFrame_1.Size = UDim2.new(1, 0, 1, 0)
ApplyThemeGradient(ColorFrame_1, 48)
UICorner_2.Parent = ColorFrame_1
UICorner_3.Parent = Check_1
ImageLabel_2.Name = RandomName()
ImageLabel_2.Parent = ColorFrame_1
ImageLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel_2.BackgroundTransparency = 1
ImageLabel_2.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel_2.Size = UDim2.new(0, 13, 0, 13)
ImageLabel_2.Image = GetIcon("check") ImageLabel_2.ScaleType = Enum.ScaleType.Crop
local function SetToggle(newVal, noSave)
DefaultVal = newVal
if not noSave then SaveConfig(Flag, DefaultVal)
end
task.spawn(Callback, DefaultVal)
if not DefaultVal then
tw({v = ColorFrame_1, t = 0.25, s =
"Quart", d = "Out", g = {BackgroundTransparency = 1}}):Play()
tw({v = ImageLabel_2, t = 0.2, s = "Back",
d = "In", g = {Size = UDim2.new(0, 0, 0, 0)}}):Play()
tw({v = Title_T, t = 0.2, s = "Quart", d =
"Out", g = {TextTransparency = 0.5}}):Play()
else
tw({v = ColorFrame_1, t = 0.25, s =
"Quart", d = "Out", g = {BackgroundTransparency = 0}}):Play()
tw({v = Title_T, t = 0.2, s = "Quart", d =
"Out", g = {TextTransparency = 0}}):Play()
tw({v = ImageLabel_2, t = 0.14, s =
"Back", d = "Out", g = {Size = UDim2.new(0, 19, 0, 19)}}):Play()
task.delay(0.1, function()
tw({v = ImageLabel_2, t = 0.18, s =
"Back", d = "Out", g = {Size = UDim2.new(0, 13, 0, 13)}}):Play()
end)
end
end
TrackConn(ClickToggle.MouseButton1Click:Connect(function()
EffectClick(ClickToggle, ToggleFrame, true)
SetToggle(not DefaultVal)
end))
SetToggle(DefaultVal, true)
local Index = {}
function Index:Title(v) Title_T.Text = tostring(v) end
function Index:Desc(v) Desc_T.Text = tostring(v or
TDesc) end
function Index:Value(v) SetToggle(v) end
function Index:Visible(v) ToggleFrame.Visible = v end
return Index
end
function ClassObj:Paragraph(pMeta)
pMeta = pMeta or {}
local PTitle = pMeta.Title or "Paragraph" local PDesc = pMeta.Desc or ""
local Paragarp = Instance.new("Frame")
local UICorner_P = Instance.new("UICorner")
local ImageLabel_P = Instance.new("ImageLabel")
local Inside_1 = Instance.new("Frame")
local UIListLayout_P = Instance.new("UIListLayout")
local Title_P = Instance.new("TextLabel")
local Desc_P = Instance.new("TextLabel")
local UIPadding_P = Instance.new("UIPadding")
Paragarp.Name = RandomName()
Paragarp.Parent = Section_1
Paragarp.AnchorPoint = Vector2.new(0.5, 0.5)
Paragarp.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Paragarp.BackgroundTransparency = 0.5
Paragarp.BorderSizePixel = 0
Paragarp.Size = UDim2.new(0.97, 0, 0, 70)
Paragarp.ClipsDescendants = true
UICorner_P.Parent = Paragarp
UICorner_P.CornerRadius = UDim.new(0, 6)
ImageLabel_P.Parent = Paragarp
ImageLabel_P.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel_P.BackgroundTransparency = 1
ImageLabel_P.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel_P.Size = UDim2.new(1, 50, 1, 0)
ImageLabel_P.Image = "rbxassetid://72380279434385"
ImageLabel_P.ImageTransparency = 0.9
ImageLabel_P.ScaleType = Enum.ScaleType.Crop
ApplyThemeGradient(ImageLabel_P)
Inside_1.Parent = Paragarp
Inside_1.AnchorPoint = Vector2.new(0.5, 0.5)
Inside_1.BackgroundTransparency = 1
Inside_1.Position = UDim2.new(0.5, 0, 0.5, 0)
Inside_1.Size = UDim2.new(1, 0, 1, 0)
UIListLayout_P.Parent = Inside_1
UIListLayout_P.Padding = UDim.new(0, 2)
UIListLayout_P.SortOrder = Enum.SortOrder.LayoutOrder
Title_P.Parent = Inside_1
Title_P.BackgroundTransparency = 1
Title_P.Size = UDim2.new(0.93, 0, 0, 16)
Title_P.Font = Enum.Font.GothamBold
Title_P.RichText = true Title_P.Text = PTitle
Title_P.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_P.TextSize = 14
Title_P.TextXAlignment = Enum.TextXAlignment.Left
Desc_P.Parent = Inside_1
Desc_P.BackgroundTransparency = 1
Desc_P.Size = UDim2.new(0.93, 0, 0, 0)
Desc_P.Font = Enum.Font.GothamBold
Desc_P.RichText = true
Desc_P.Text = PDesc
Desc_P.TextColor3 = Color3.fromRGB(255, 255, 255)
Desc_P.TextSize = 10
Desc_P.TextTransparency = 0.5
Desc_P.TextWrapped = true
Desc_P.TextXAlignment = Enum.TextXAlignment.Left
Desc_P.TextYAlignment = Enum.TextYAlignment.Top
UIPadding_P.Parent = Inside_1
UIPadding_P.PaddingLeft = UDim.new(0, 10)
UIPadding_P.PaddingTop = UDim.new(0, 6)
local function RefreshBounds()
task.defer(function()
local descHeight = Desc_P.TextBounds.Y + 6
Desc_P.Size = UDim2.new(0.93, 0, 0,
descHeight)
Paragarp.Size = UDim2.new(0.97, 0, 0,
descHeight + 30)
end)
end
RefreshBounds()
local Index = {}
function Index:Title(v) Title_P.Text = tostring(v) end
function Index:Desc(v) Desc_P.Text = tostring(v);
RefreshBounds() end
function Index:Visible(v) Paragarp.Visible = v end
return Index
end
ClassObj.Paragarp = ClassObj.Paragraph
function ClassObj:Textbox(tbMeta)
tbMeta = tbMeta or {}
local Flag = tbMeta.Flag or tbMeta.PlaceHolder or
"Textbox"
local Value = SavedConfig[Flag] ~= nil and
SavedConfig[Flag] or (tbMeta.Value or "Example") local PlaceHolder = tbMeta.PlaceHolder or "Input..."
local ClearOnFocus = tbMeta.ClearOnFocus or false
local Callback = tbMeta.Callback or function() end
local Textbox = Instance.new("Frame")
local UICorner_TB = Instance.new("UICorner")
local ImageLabel_TB = Instance.new("ImageLabel")
local Edit_1 = Instance.new("TextBox")
local UICorner_2 = Instance.new("UICorner")
local UIStroke_1 = Instance.new("UIStroke")
Textbox.Name = RandomName()
Textbox.Parent = Section_1
Textbox.AnchorPoint = Vector2.new(0.5, 0.5)
Textbox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Textbox.BackgroundTransparency = 0.5
Textbox.BorderSizePixel = 0
Textbox.Size = UDim2.new(0.97, 0, 0, 40)
Textbox.ClipsDescendants = true
UICorner_TB.Parent = Textbox
UICorner_TB.CornerRadius = UDim.new(0, 6)
ImageLabel_TB.Parent = Textbox
ImageLabel_TB.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel_TB.BackgroundTransparency = 1
ImageLabel_TB.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel_TB.Size = UDim2.new(1, 50, 1, 0)
ImageLabel_TB.Image = "rbxassetid://72380279434385"
ImageLabel_TB.ImageTransparency = 0.9
ImageLabel_TB.ScaleType = Enum.ScaleType.Crop
ApplyThemeGradient(ImageLabel_TB)
Edit_1.Parent = Textbox
Edit_1.Active = true
Edit_1.AnchorPoint = Vector2.new(0.5, 0.5)
Edit_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Edit_1.BackgroundTransparency = 0.85
Edit_1.BorderSizePixel = 0
Edit_1.Position = UDim2.new(0.5, 0, 0.5, 0)
Edit_1.Size = UDim2.new(0.95, 0, 0.7, 0)
Edit_1.Font = Enum.Font.GothamBold
Edit_1.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
Edit_1.PlaceholderText = tostring(PlaceHolder)
Edit_1.RichText = true
Edit_1.Text = tostring(Value)
Edit_1.TextColor3 = Color3.fromRGB(255, 255, 255)
Edit_1.TextSize = 14 Edit_1.ClearTextOnFocus = ClearOnFocus
ApplyThemeGradient(Edit_1)
UICorner_2.Parent = Edit_1
UICorner_2.CornerRadius = UDim.new(1, 0)
UIStroke_1.Parent = Edit_1
UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_1.Color = Color3.fromRGB(255, 255, 255)
UIStroke_1.Thickness = 1
UIStroke_1.Transparency = 0.5
ApplyThemeGradient(UIStroke_1)
TrackConn(Edit_1.FocusLost:Connect(function()
if #Edit_1.Text > 0 then
SaveConfig(Flag, Edit_1.Text)
pcall(Callback, Edit_1.Text)
end
tw({v = UIStroke_1, t = 0.25, s = "Quart", d =
"Out", g = {Transparency = 0.5}}):Play()
end))
TrackConn(Edit_1.Focused:Connect(function()
tw({v = UIStroke_1, t = 0.25, s = "Quart", d =
"Out", g = {Transparency = 0}}):Play()
end))
local Index = {}
function Index:Value(v) Edit_1.Text = tostring(v) end
function Index:Visible(v) Textbox.Visible = v end
return Index
end
function ClassObj:Slider(info)
info = info or {}
local STitle = info.Title or "Slider"
local Min = info.Min or 0
local Max = info.Max or 100
local Rounding = info.Rounding or 0
local Flag = info.Flag or STitle
local Value = SavedConfig[Flag] ~= nil and
SavedConfig[Flag] or (info.Value or Min)
local Callback = info.Callback or info.CallBack or
function() end
local Slider = Instance.new("Frame")
local UICorner_S = Instance.new("UICorner")
local ImageLabel_S = Instance.new("ImageLabel") local Title_S = Instance.new("TextLabel")
local Bar_1 = Instance.new("Frame")
local UICorner_2 = Instance.new("UICorner")
local BarValue_1 = Instance.new("Frame")
local UICorner_3 = Instance.new("UICorner")
local ValueBox_1 = Instance.new("TextBox")
local UICorner_4 = Instance.new("UICorner")
local Slide = click(Bar_1)
Slider.Name = RandomName()
Slider.Parent = Section_1
Slider.AnchorPoint = Vector2.new(0.5, 0.5)
Slider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Slider.BackgroundTransparency = 0.5
Slider.BorderSizePixel = 0
Slider.Size = UDim2.new(0.97, 0, 0, 60)
Slider.ClipsDescendants = true
AddHoverEffect(Slider, 0.5)
UICorner_S.Parent = Slider
UICorner_S.CornerRadius = UDim.new(0, 6)
ImageLabel_S.Parent = Slider
ImageLabel_S.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel_S.BackgroundTransparency = 1
ImageLabel_S.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel_S.Size = UDim2.new(1, 50, 1, 0)
ImageLabel_S.Image = "rbxassetid://72380279434385"
ImageLabel_S.ImageTransparency = 0.9
ImageLabel_S.ScaleType = Enum.ScaleType.Crop
ApplyThemeGradient(ImageLabel_S)
Title_S.Parent = Slider
Title_S.BackgroundTransparency = 1
Title_S.Position = UDim2.new(0.036, 0, 0.085, 0)
Title_S.Size = UDim2.new(0.928, 0, 0, 20)
Title_S.Font = Enum.Font.GothamBold
Title_S.Text = STitle
Title_S.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_S.TextSize = 14
Title_S.TextXAlignment = Enum.TextXAlignment.Left
Bar_1.Parent = Slider
Bar_1.AnchorPoint = Vector2.new(0.5, 0.5)
Bar_1.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
Bar_1.BorderSizePixel = 0
Bar_1.Position = UDim2.new(0.5, 0, 0.65, 0)
Bar_1.Size = UDim2.new(0, 253, 0, 18) Bar_1.ClipsDescendants = true
UICorner_2.Parent = Bar_1
UICorner_2.CornerRadius = UDim.new(1, 0)
BarValue_1.Parent = Bar_1
BarValue_1.AnchorPoint = Vector2.new(0, 0.5)
BarValue_1.BackgroundColor3 = Color3.fromRGB(255, 255,
255)
BarValue_1.BorderSizePixel = 0
BarValue_1.Position = UDim2.new(0, 0, 0.5, 0)
BarValue_1.Size = UDim2.new(0, 0, 1, 0)
ApplyThemeGradient(BarValue_1)
UICorner_3.Parent = BarValue_1
UICorner_3.CornerRadius = UDim.new(1, 0)
ValueBox_1.Parent = Slider
ValueBox_1.Active = true
ValueBox_1.AnchorPoint = Vector2.new(1, 0.5)
ValueBox_1.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
ValueBox_1.BorderSizePixel = 0
ValueBox_1.Position = UDim2.new(0.95, 0, 0.25, 0)
ValueBox_1.Size = UDim2.new(0, 32, 0, 16)
ValueBox_1.Font = Enum.Font.GothamBold
ValueBox_1.PlaceholderText = tostring(Value)
ValueBox_1.Text = tostring(Value)
ValueBox_1.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueBox_1.TextSize = 10
ValueBox_1.TextTransparency = 0.25
UICorner_4.Parent = ValueBox_1
UICorner_4.CornerRadius = UDim.new(1, 0)
local function roundToDecimal(val, decimals)
local factor = 10 ^ decimals
return math.floor(val * factor + 0.5) / factor
end
local function updateSlider(val, noSave)
val = math.clamp(val, Min, Max)
val = roundToDecimal(val, Rounding)
Value = val
if not noSave then SaveConfig(Flag, Value) end
local ratio = (Max - Min) > 0 and ((val - Min) /
(Max - Min)) or 0
tw({ v = BarValue_1,
t = 0.1,
s = "Quart",
d = "Out",
g = {Size = UDim2.new(ratio, 0, 1, 0)}
}):Play()
ValueBox_1.Text = tostring(val)
ValueBox_1.Size = UDim2.new(0, math.max(28,
ValueBox_1.TextBounds.X + 16), 0, 16)
task.spawn(Callback, val)
end
updateSlider(Value, true)
TrackConn(ValueBox_1.FocusLost:Connect(function()
local val = tonumber(ValueBox_1.Text) or Min
updateSlider(val)
end))
local function move(input)
local relativeX = math.clamp((input.Position.X -
Bar_1.AbsolutePosition.X) / Bar_1.AbsoluteSize.X, 0, 1)
local val = relativeX * (Max - Min) + Min
updateSlider(val)
end
local dragging = false
TrackConn(Slide.InputBegan:Connect(function(input)
if input.UserInputType ==
Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
then
dragging = true
move(input)
end
end))
TrackConn(Slide.InputEnded:Connect(function(input)
if input.UserInputType ==
Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
then
dragging = false
end
end))
TrackConn(UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType ==
Enum.UserInputType.MouseMovement or input.UserInputType ==
Enum.UserInputType.Touch) then
move(input)
end
end))
local NewValue = {}
function NewValue:SetValue(a) updateSlider(a) end
function NewValue:Visible(a) Slider.Visible = a end
function NewValue:Title(b) Title_S.Text = tostring(b)
end
return NewValue
end
function ClassObj:Dropdown(info)
info = info or {}
local DTitle = info.Title or "Dropdown"
local List = info.List or {}
local Flag = info.Flag or DTitle
local Value = SavedConfig[Flag] ~= nil and
SavedConfig[Flag] or info.Value
local Multi = info.Multi or false
local Callback = info.Callback or function() end
local Dropdownz = Instance.new("Frame")
local UICorner_D = Instance.new("UICorner")
local ImageLabel_D = Instance.new("ImageLabel")
local Title_D = Instance.new("TextLabel")
local Desc_D = Instance.new("TextLabel")
local icon_D = Instance.new("ImageLabel")
local ClickDropdown = click(Dropdownz)
Dropdownz.Name = RandomName()
Dropdownz.Parent = Section_1
Dropdownz.AnchorPoint = Vector2.new(0.5, 0.5)
Dropdownz.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Dropdownz.BackgroundTransparency = 0.5
Dropdownz.BorderSizePixel = 0
Dropdownz.Size = UDim2.new(0.97, 0, 0, 45)
Dropdownz.ClipsDescendants = true
AddHoverEffect(Dropdownz, 0.5)
UICorner_D.Parent = Dropdownz
UICorner_D.CornerRadius = UDim.new(0, 6)
ImageLabel_D.Parent = Dropdownz
ImageLabel_D.AnchorPoint = Vector2.new(0.5, 0.5) ImageLabel_D.BackgroundTransparency = 1
ImageLabel_D.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel_D.Size = UDim2.new(1, 50, 1, 0)
ImageLabel_D.Image = "rbxassetid://72380279434385"
ImageLabel_D.ImageTransparency = 0.9
ImageLabel_D.ScaleType = Enum.ScaleType.Crop
ApplyThemeGradient(ImageLabel_D)
Title_D.Parent = Dropdownz
Title_D.BackgroundTransparency = 1
Title_D.Position = UDim2.new(0.036, 0, 0.085, 0)
Title_D.Size = UDim2.new(0.928, 0, 0, 20)
Title_D.Font = Enum.Font.GothamBold
Title_D.Text = DTitle
Title_D.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_D.TextSize = 14
Title_D.TextXAlignment = Enum.TextXAlignment.Left
Desc_D.Parent = Dropdownz
Desc_D.BackgroundTransparency = 1
Desc_D.Position = UDim2.new(0.036, 0, 0.435, 0)
Desc_D.Size = UDim2.new(0.928, 0, 0, 20)
Desc_D.Font = Enum.Font.GothamBold
Desc_D.Text = type(Value) == "table" and
table.concat(Value, ", ") or tostring(Value or "")
Desc_D.TextColor3 = Color3.fromRGB(255, 255, 255)
Desc_D.TextSize = 12
Desc_D.TextXAlignment = Enum.TextXAlignment.Left
ApplyThemeGradient(Desc_D, 90)
icon_D.Parent = Dropdownz
icon_D.AnchorPoint = Vector2.new(0.5, 0.5)
icon_D.BackgroundTransparency = 1
icon_D.Position = UDim2.new(0.9, 0, 0.5, 0)
icon_D.Size = UDim2.new(0, 28, 0, 28)
icon_D.Image = GetIcon("dropdown")
icon_D.ScaleType = Enum.ScaleType.Crop
ApplyThemeGradient(icon_D)
local Dropdown = Instance.new("Frame")
local UICorner_Panel = Instance.new("UICorner")
local Effect_P = Instance.new("ImageLabel")
local Head_1 = Instance.new("Frame")
local Title_P = Instance.new("TextLabel")
local Line_P = Instance.new("Frame")
local Body_1 = Instance.new("Frame")
local Search_1 = Instance.new("TextBox")
local UICorner_S = Instance.new("UICorner") local UIStroke_S = Instance.new("UIStroke")
local UIListLayout_B = Instance.new("UIListLayout")
local ScrollingFrame_D = Instance.new("ScrollingFrame")
local UIListLayout_List = Instance.new("UIListLayout")
Dropdown.Parent = Background_1
Dropdown.AnchorPoint = Vector2.new(1, 0.5)
Dropdown.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Dropdown.BackgroundTransparency = 0.08
Dropdown.BorderSizePixel = 0
Dropdown.Position = UDim2.new(1, 0, 0.5, 0)
Dropdown.Size = UDim2.new(0, 0, 1, 0)
Dropdown.ClipsDescendants = true
Dropdown.ZIndex = 15
UICorner_Panel.Parent = Dropdown
UICorner_Panel.CornerRadius = UDim.new(0, 14)
Effect_P.Parent = Dropdown
Effect_P.AnchorPoint = Vector2.new(0.5, 0.5)
Effect_P.BackgroundTransparency = 1
Effect_P.Position = UDim2.new(0.5, 0, 0.5, 0)
Effect_P.Size = UDim2.new(1, 0, 1, 0)
Effect_P.Image = "rbxassetid://132687652275989"
Effect_P.ImageColor3 = Color3.fromRGB(0, 255, 127)
Effect_P.ImageTransparency = 0.5
Effect_P.ScaleType = Enum.ScaleType.Crop
Head_1.Parent = Dropdown
Head_1.BackgroundTransparency = 1
Head_1.Size = UDim2.new(1, 0, 0, 60)
Title_P.Parent = Head_1
Title_P.AnchorPoint = Vector2.new(0.5, 0.5)
Title_P.BackgroundTransparency = 1
Title_P.Position = UDim2.new(0.55, 0, 0.41, 0)
Title_P.Size = UDim2.new(0.916, 0, 0.44, 0)
Title_P.Font = Enum.Font.GothamBold
Title_P.Text = DTitle
Title_P.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_P.TextSize = 18
Title_P.TextXAlignment = Enum.TextXAlignment.Left
Line_P.Parent = Head_1
Line_P.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Line_P.BorderSizePixel = 0
Line_P.Position = UDim2.new(0, 20, 0, 37)
Line_P.Size = UDim2.new(0, 70, 0, 2) ApplyThemeGradient(Line_P)
Body_1.Parent = Dropdown
Body_1.BackgroundTransparency = 1
Body_1.Position = UDim2.new(0, 0, 0.13, 0)
Body_1.Size = UDim2.new(1, 0, 0.71, 60)
Search_1.Parent = Body_1
Search_1.Active = true
Search_1.AnchorPoint = Vector2.new(0.5, 0.5)
Search_1.BackgroundColor3 = Color3.fromRGB(255, 255,
255)
Search_1.BackgroundTransparency = 0.9
Search_1.BorderSizePixel = 0
Search_1.Position = UDim2.new(0.5, 0, 0.032, 0)
Search_1.Size = UDim2.new(0.9, 0, 0.065, 0)
Search_1.Font = Enum.Font.GothamBold
Search_1.PlaceholderColor3 = Color3.fromRGB(178, 178,
178)
Search_1.PlaceholderText = "Search..."
Search_1.Text = ""
Search_1.TextColor3 = Color3.fromRGB(255, 255, 255)
Search_1.TextSize = 13
ApplyThemeGradient(Search_1)
UICorner_S.Parent = Search_1
UICorner_S.CornerRadius = UDim.new(1, 0)
UIStroke_S.Parent = Search_1
UIStroke_S.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_S.Color = Color3.fromRGB(255, 255, 255)
UIStroke_S.Thickness = 1
ApplyThemeGradient(UIStroke_S)
UIListLayout_B.Parent = Body_1
UIListLayout_B.Padding = UDim.new(0, 7)
UIListLayout_B.HorizontalAlignment =
Enum.HorizontalAlignment.Center
UIListLayout_B.SortOrder = Enum.SortOrder.LayoutOrder
ScrollingFrame_D.Parent = Body_1
ScrollingFrame_D.Active = true
ScrollingFrame_D.BackgroundTransparency = 1
ScrollingFrame_D.BorderSizePixel = 0
ScrollingFrame_D.Position = UDim2.new(0.05, 0, 0.087, 0)
ScrollingFrame_D.Size = UDim2.new(0.9, 0, 0.886, 0)
ScrollingFrame_D.ClipsDescendants = true
ScrollingFrame_D.ScrollBarThickness = 0 ScrollingFrame_D.ScrollingDirection =
Enum.ScrollingDirection.Y
UIListLayout_List.Parent = ScrollingFrame_D
UIListLayout_List.Padding = UDim.new(0, 5)
UIListLayout_List.SortOrder = Enum.SortOrder.LayoutOrder
local isOpen = false
TrackConn(UserInputService.InputBegan:Connect(function(A)
if isOpen and (A.UserInputType ==
Enum.UserInputType.MouseButton1 or A.UserInputType == Enum.UserInputType.Touch)
then
local B, C = Dropdown.AbsolutePosition,
Dropdown.AbsoluteSize
if Mouse.X < B.X or Mouse.X > B.X + C.X or
Mouse.Y < (B.Y - 21) or Mouse.Y > B.Y + C.Y then
isOpen = false
tw({v = Dropdown, t = 0.25, s =
"Quart", d = "Out", g = {Size = UDim2.new(0, 0, 1, 0)}}):Play()
end
end
end))
TrackConn(ClickDropdown.MouseButton1Click:Connect(function()
isOpen = not isOpen
if isOpen then
tw({v = Dropdown, t = 0.3, s = "Back", d =
"Out", g = {Size = UDim2.new(0, 215, 1, 0)}}):Play()
else
tw({v = Dropdown, t = 0.25, s = "Quart", d
= "Out", g = {Size = UDim2.new(0, 0, 1, 0)}}):Play()
end
EffectClick(ClickDropdown, Dropdownz, true)
end))
local ItemRecords = {}
TrackConn(Search_1:GetPropertyChangedSignal("Text"):Connect(function()
local SearchT = string.lower(Search_1.Text)
for _, rec in ipairs(ItemRecords) do
if rec.Frame and rec.Frame.Parent then
local match =
string.find(string.lower(rec.Text), SearchT, 1, true) ~= nil
rec.Frame.Visible = match
end
end end))
local itemslist = {}
local selectedValues = {}
local function isValueInTable(val, tbl)
if type(tbl) ~= "table" then return false end
for _, v in pairs(tbl) do if v == val then return
true end end
return false
end
function itemslist:AddList(text)
text = tostring(text)
local Items = Instance.new("Frame")
local Real_1 = Instance.new("Frame")
local Title_Item = Instance.new("TextLabel")
local Line_Item = Instance.new("Frame")
local UICorner_I = Instance.new("UICorner")
local ClickList = click(Items)
Items.Parent = ScrollingFrame_D
Items.BackgroundColor3 = Color3.fromRGB(255, 255,
255)
Items.BackgroundTransparency = 0.9
Items.BorderSizePixel = 0
Items.Size = UDim2.new(1, 0, 0, 30)
ApplyThemeGradient(Items)
Real_1.Parent = Items
Real_1.AnchorPoint = Vector2.new(0.5, 0.5)
Real_1.BackgroundTransparency = 1
Real_1.Position = UDim2.new(0.5, 0, 0.5, 0)
Real_1.Size = UDim2.new(1, 0, 1, 0)
Title_Item.Parent = Real_1
Title_Item.AnchorPoint = Vector2.new(0.5, 0.5)
Title_Item.BackgroundTransparency = 1
Title_Item.Position = UDim2.new(0.542, 0, 0.5, 0)
Title_Item.Size = UDim2.new(0.916, 0, 1, 0)
Title_Item.Font = Enum.Font.GothamBold
Title_Item.Text = text
Title_Item.TextColor3 = Color3.fromRGB(255, 255,
255)
Title_Item.TextSize = 14
Title_Item.TextXAlignment =
Enum.TextXAlignment.Left
Title_Item.TextTransparency = 0.5 Line_Item.Parent = Real_1
Line_Item.AnchorPoint = Vector2.new(0, 0.5)
Line_Item.BackgroundColor3 = Color3.fromRGB(255,
255, 255)
Line_Item.BorderSizePixel = 0
Line_Item.Position = UDim2.new(0, 0, 0.5, 0)
Line_Item.Size = UDim2.new(0, 5, 0, 30)
Line_Item.BackgroundTransparency = 1
ApplyThemeGradient(Line_Item, 90)
UICorner_I.Parent = Line_Item
UICorner_I.CornerRadius = UDim.new(1, 0)
table.insert(ItemRecords, {Frame = Items, Title =
Title_Item, Line = Line_Item, Text = text})
TrackConn(ClickList.MouseButton1Click:Connect(function()
if Multi then
if selectedValues[text] then
selectedValues[text] = nil
tw({v = Title_Item, t = 0.15,
s = "Quart", d = "Out", g = {TextTransparency = 0.5}}):Play()
tw({v = Line_Item, t = 0.15,
s = "Quart", d = "Out", g = {BackgroundTransparency = 1}}):Play()
else
selectedValues[text] = true
tw({v = Title_Item, t = 0.15,
s = "Quart", d = "Out", g = {TextTransparency = 0}}):Play()
tw({v = Line_Item, t = 0.15,
s = "Quart", d = "Out", g = {BackgroundTransparency = 0}}):Play()
end
local selectedList = {}
for k in pairs(selectedValues) do
table.insert(selectedList, k) end
Desc_D.Text = #selectedList > 0 and
table.concat(selectedList, ", ") or ""
SaveConfig(Flag, selectedList)
pcall(Callback, selectedList)
else
for _, r in ipairs(ItemRecords) do
tw({v = r.Title, t = 0.15, s
= "Quart", d = "Out", g = {TextTransparency = 0.5}}):Play()
tw({v = r.Line, t = 0.15, s =
"Quart", d = "Out", g = {BackgroundTransparency = 1}}):Play()
end tw({v = Title_Item, t = 0.15, s =
"Quart", d = "Out", g = {TextTransparency = 0}}):Play()
tw({v = Line_Item, t = 0.15, s =
"Quart", d = "Out", g = {BackgroundTransparency = 0}}):Play()
tw({v = Dropdown, t = 0.25, s =
"Quart", d = "Out", g = {Size = UDim2.new(0, 0, 1, 0)}}):Play()
isOpen = false
Value = text
Desc_D.Text = text
SaveConfig(Flag, text)
pcall(Callback, text)
end
end))
task.defer(function()
if Multi and isValueInTable(text, Value)
then
selectedValues[text] = true
Title_Item.TextTransparency = 0
Line_Item.BackgroundTransparency = 0
local selectedList = {}
for k in pairs(selectedValues) do
table.insert(selectedList, k) end
Desc_D.Text =
table.concat(selectedList, ", ")
pcall(Callback, selectedList)
elseif not Multi and text == Value then
Title_Item.TextTransparency = 0
Line_Item.BackgroundTransparency = 0
Desc_D.Text = text
pcall(Callback, text)
end
end)
end
for _, v in ipairs(List) do itemslist:AddList(v) end
TrackConn(UIListLayout_List:GetPropertyChangedSignal("AbsoluteContentSize"):Connec
t(function()
ScrollingFrame_D.CanvasSize = UDim2.new(0, 0, 0,
UIListLayout_List.AbsoluteContentSize.Y + 5)
end))
return itemslist
end
function ClassObj:Keybind(info)
info = info or {} local KTitle = info.Title or "Keybind"
local Flag = info.Flag or KTitle
local Key = SavedConfig[Flag] ~= nil and
SavedConfig[Flag] or (info.Key or Enum.KeyCode.Q)
local Value = info.Value or false
local Callback = info.Callback or function() end
local Keybind = Instance.new("Frame")
local UICorner_K = Instance.new("UICorner")
local ImageLabel_K = Instance.new("ImageLabel")
local Title_K = Instance.new("TextLabel")
local Bin_1 = Instance.new("Frame")
local UICorner_2 = Instance.new("UICorner")
local TextLabel_1 = Instance.new("TextLabel")
local ClickChange = click(Keybind)
Keybind.Name = RandomName()
Keybind.Parent = Section_1
Keybind.AnchorPoint = Vector2.new(0.5, 0.5)
Keybind.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Keybind.BackgroundTransparency = 0.5
Keybind.BorderSizePixel = 0
Keybind.Size = UDim2.new(0.97, 0, 0, 45)
Keybind.ClipsDescendants = true
AddHoverEffect(Keybind, 0.5)
UICorner_K.Parent = Keybind
UICorner_K.CornerRadius = UDim.new(0, 6)
ImageLabel_K.Parent = Keybind
ImageLabel_K.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel_K.BackgroundTransparency = 1
ImageLabel_K.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel_K.Size = UDim2.new(1, 50, 1, 0)
ImageLabel_K.Image = "rbxassetid://72380279434385"
ImageLabel_K.ImageTransparency = 0.9
ImageLabel_K.ScaleType = Enum.ScaleType.Crop
ApplyThemeGradient(ImageLabel_K)
Title_K.Parent = Keybind
Title_K.AnchorPoint = Vector2.new(0.5, 0.5)
Title_K.BackgroundTransparency = 1
Title_K.Position = UDim2.new(0.5, 0, 0.5, 0)
Title_K.Size = UDim2.new(0.928, 0, 0, 20)
Title_K.Font = Enum.Font.GothamBold
Title_K.Text = KTitle
Title_K.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_K.TextSize = 14 if input.UserInputType ==
Enum.UserInputType.Keyboard then
Key = input.KeyCode
TextLabel_1.Text =
tostring(Key):gsub("Enum.KeyCode.", "")
adjustBoxBindSize()
inputConnection:Disconnect()
binding = false
SaveConfig(Flag, tostring(Key))
tw({v = Title_K, t = 0.15, s =
"Quart", d = "Out", g = {TextTransparency = Value and 0 or 0.5}}):Play()
task.spawn(Callback, Key, Value)
end
end)
end
TrackConn(UserInputService.InputEnded:Connect(function(input, gameProcessed)
if not gameProcessed and not binding and
input.KeyCode == Key then
Value = not Value
tw({v = Title_K, t = 0.15, s = "Quart", d
= "Out", g = {TextTransparency = Value and 0 or 0.5}}):Play()
tw({v = Bin_1, t = 0.15, s = "Quart", d =
"Out", g = {BackgroundTransparency = Value and 0 or 0.5}}):Play()
task.spawn(Callback, Key, Value)
end
end))
TrackConn(ClickChange.MouseButton1Click:Connect(function()
changeKey()
EffectClick(ClickChange, Keybind, true)
end))
end
return ClassObj
end
return SectionBuilder
end
return WindowObj
end
return Env