local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local isLoopActive = false
local isEscapeActive = true -- 葉っぱ全滅時自分TPの初期状態（ON）
local waitTime = 1.0
local maxAmount = 20

local escapePosition = Vector3.new(24.298, 51.743, -65.026)

-- Tweenのアニメーション設定
local TWEEN_DURATION = 0.5 
local tweenInfo = TweenInfo.new(
    TWEEN_DURATION,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out
)

-- ==========================================
-- 1. スタイリッシュGUIの作成（Ranked削除・コンパクト化）
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XenoLeafPremiumPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- メインフレーム
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 210)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(45, 45, 50)
frameStroke.Thickness = 1.5
frameStroke.Parent = mainFrame

-- タイトルラベル
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Leaf TP Panel"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- メインON/OFFボタン
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 38)
toggleButton.Position = UDim2.new(0.05, 0, 0.16, 5)
toggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Text = "AUTO TP: DISABLED"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleButton

toggleButton.MouseButton1Click:Connect(function()
    isLoopActive = not isLoopActive
    if isLoopActive then
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 140, 80)
        toggleButton.Text = "AUTO TP: ENABLED"
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        toggleButton.Text = "AUTO TP: DISABLED"
    end
end)

-- 自分TP（Auto Escape）ON/OFFボタン
local escapeButton = Instance.new("TextButton")
escapeButton.Size = UDim2.new(0.9, 0, 0, 32)
escapeButton.Position = UDim2.new(0.05, 0, 0.36, 5)
escapeButton.BackgroundColor3 = Color3.fromRGB(0, 140, 80)
escapeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
escapeButton.TextSize = 12
escapeButton.Text = "LEAF GONE TP: ON"
escapeButton.Font = Enum.Font.GothamBold
escapeButton.Parent = mainFrame

local escCorner = Instance.new("UICorner")
escCorner.CornerRadius = UDim.new(0, 8)
escCorner.Parent = escapeButton

escapeButton.MouseButton1Click:Connect(function()
    isEscapeActive = not isEscapeActive
    if isEscapeActive then
        escapeButton.BackgroundColor3 = Color3.fromRGB(0, 140, 80)
        escapeButton.Text = "LEAF GONE TP: ON"
    else
        escapeButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        escapeButton.Text = "LEAF GONE TP: OFF"
    end
end)

-- --- スライダー1: 待機時間 ---
local timeTrack = Instance.new("Frame")
timeTrack.Size = UDim2.new(0.9, 0, 0, 6)
timeTrack.Position = UDim2.new(0.05, 0, 0.54, 10)
timeTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
timeTrack.BorderSizePixel = 0
timeTrack.Parent = mainFrame

local trackCorner1 = Instance.new("UICorner") trackCorner1.CornerRadius = UDim.new(0, 3) trackCorner1.Parent = timeTrack

local timeBtn = Instance.new("TextButton")
timeBtn.Size = UDim2.new(0, 14, 0, 14)
timeBtn.AnchorPoint = Vector2.new(0.5, 0.5)
timeBtn.Position = UDim2.new(0.2, 0, 0.5, 0)
timeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
timeBtn.Text = ""
timeBtn.Parent = timeTrack

local btnCorner1 = Instance.new("UICorner") btnCorner1.CornerRadius = UDim.new(1, 0) btnCorner1.Parent = timeBtn

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(1, 0, 0, 18)
timeLabel.Position = UDim2.new(0, 0, 0.59, 10)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "Wait Time: 1.00s"
timeLabel.TextColor3 = Color3.fromRGB(180, 180, 185)
timeLabel.TextSize = 12
timeLabel.Font = Enum.Font.Gotham
timeLabel.Parent = mainFrame

-- --- スライダー2: 回収個数 ---
local amtTrack = Instance.new("Frame")
amtTrack.Size = UDim2.new(0.9, 0, 0, 6)
amtTrack.Position = UDim2.new(0.05, 0, 0.76, 10)
amtTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
amtTrack.BorderSizePixel = 0
amtTrack.Parent = mainFrame

local trackCorner2 = Instance.new("UICorner") trackCorner2.CornerRadius = UDim.new(0, 3) trackCorner2.Parent = amtTrack

local amtBtn = Instance.new("TextButton")
amtBtn.Size = UDim2.new(0, 14, 0, 14)
amtBtn.AnchorPoint = Vector2.new(0.5, 0.5)
amtBtn.Position = UDim2.new(0.2, 0, 0.5, 0)
amtBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
amtBtn.Text = ""
amtBtn.Parent = amtTrack

local btnCorner2 = Instance.new("UICorner") btnCorner2.CornerRadius = UDim.new(1, 0) btnCorner2.Parent = amtBtn

local amtLabel = Instance.new("TextLabel")
amtLabel.Size = UDim2.new(1, 0, 0, 18)
amtLabel.Position = UDim2.new(0, 0, 0.81, 10)
amtLabel.BackgroundTransparency = 1
amtLabel.Text = "Max Amount: 20"
amtLabel.TextColor3 = Color3.fromRGB(180, 180, 185)
amtLabel.TextSize = 12
amtLabel.Font = Enum.Font.Gotham
amtLabel.Parent = mainFrame

-- ==========================================
-- 2. スライダー動作ロジック
-- ==========================================
local activeSlider = nil

local function updateSlider(input)
    if not activeSlider then return end
    local track = activeSlider == "time" and timeTrack or amtTrack
    local btn = activeSlider == "time" and timeBtn or amtBtn
    
    local trackWidth = track.AbsoluteSize.X
    local mouseX = input.Position.X - track.AbsolutePosition.X
    local percentage = math.clamp(mouseX / trackWidth, 0, 1)
    
    btn.Position = UDim2.new(percentage, 0, 0.5, 0)
    
    if activeSlider == "time" then
        waitTime = 0.01 + (percentage * (5.0 - 0.01))
        timeLabel.Text = string.format("Wait Time: %.2fs", waitTime)
    elseif activeSlider == "amt" then
        maxAmount = math.round(1 + (percentage * (100 - 1)))
        amtLabel.Text = "Max Amount: " .. tostring(maxAmount)
    end
end

timeBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then activeSlider = "time" end end)
amtBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then activeSlider = "amt" end end)
UserInputService.InputChanged:Connect(function(input) if activeSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then activeSlider = nil end end)
-- ==========================================
-- 3. 特殊判定付きのTweenループ処理（修正版）
-- ==========================================
task.spawn(function()
    while true do
        task.wait(waitTime)
        
        if isLoopActive then
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                local leavesFolder = Workspace:FindFirstChild("Leaves")
                if leavesFolder then
                    local leaves = leavesFolder:GetChildren()
                    local validLeaves = {}
                    local currentPos = rootPart.Position
                    
                    -- すでにTween移動中のパーツや、処理済みのパーツを除外して集める
                    for _, child in ipairs(leaves) do
                        if child.Name == "Leaf" and child:IsA("BasePart") and not child:GetAttribute("Laf") and not child:GetAttribute("IsTweening") then
                            -- Y軸を除外した水平距離の計算
                            local horizTarget = Vector3.new(currentPos.X, child.Position.Y, currentPos.Z)
                            if (child.Position - horizTarget).Magnitude > 5 then
                                table.insert(validLeaves, child)
                            end
                        end
                    end
                    
                    if #validLeaves == 0 then
                        for _, child in ipairs(leaves) do
                            if child.Name == "Leaf" and child:IsA("BasePart") and not child:GetAttribute("Laf") and not child:GetAttribute("IsTweening") then
                                table.insert(validLeaves, child)
                            end
                        end
                    end
                    
                    -- 葉っぱが1つもない（または全滅した）場合の自分TP処理
                    if #validLeaves == 0 and isEscapeActive then
                        rootPart.CFrame = CFrame.new(escapePosition)
                    end
                    
                    -- 指定された最大個数（maxAmount）の分だけTweenで引き寄せる
                    local count = 0
                    for _, leaf in ipairs(validLeaves) do
                        if count >= maxAmount then 
                            break 
                        end
                        
                        -- 目標地点の作成（X, Zはプレイヤー、YはLeafの元の高さを固定）
                        local targetPosition = Vector3.new(rootPart.Position.X, leaf.Position.Y, rootPart.Position.Z)
                        
                        leaf.Anchored = true
                        leaf.CanCollide = false
                        leaf:SetAttribute("IsTweening", true) -- 二重処理防止フラグ
                        
                        local tween = TweenService:Create(leaf, tweenInfo, {Position = targetPosition})
                        tween:Play()
                        
                        -- Tween完了時に元のタグ処理を実行
                        tween.Completed:Connect(function()
                            leaf:SetAttribute("IsTweening", nil)
                            leaf:SetAttribute("Laf", true)
                        end)
                        
                        count = count + 1
                    end
                else
                    -- Leavesフォルダ自体がない場合もエスケープTP
                    if isEscapeActive then
                        rootPart.CFrame = CFrame.new(escapePosition)
                    end
                end
            end
        end
    end
end)
