local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local isLoopActive = false
local waitTime = 1.0 -- 初期状態の待機時間（1秒）

-- 指定のテレポート先座標 (Vector3)
local escapePosition = Vector3.new(24.298, 51.743, -65.026)

-- ==========================================
-- 1. GUIの作成（コントロールパネル）
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeafCollectorPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 140)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Leaf TP Panel"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 40)
toggleButton.Position = UDim2.new(0.05, 0, 0.25, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 16
toggleButton.Text = "Status: OFF"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleButton

local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(0.9, 0, 0, 10)
sliderTrack.Position = UDim2.new(0.05, 0, 0.65, 0)
sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = mainFrame

local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(0, 5)
trackCorner.Parent = sliderTrack

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(0, 16, 0, 16)
sliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
sliderBtn.Position = UDim2.new(0.2, 0, 0.5, 0)
sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderBtn.Text = ""
sliderBtn.Parent = sliderTrack

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(1, 0)
btnCorner2.Parent = sliderBtn

local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(1, 0, 0, 25)
valueLabel.Position = UDim2.new(0, 0, 0.78, 0)
valueLabel.BackgroundTransparency = 1
valueLabel.Text = "Wait Time: 1.00s"
valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
valueLabel.TextSize = 14
valueLabel.Font = Enum.Font.SourceSans
valueLabel.Parent = mainFrame

-- スライダーの動作
local minWait = 0.01
local maxWait = 5.0
local isSliding = false

local function updateSlider(input)
    local trackWidth = sliderTrack.AbsoluteSize.X
    local mouseX = input.Position.X - sliderTrack.AbsolutePosition.X
    local percentage = math.clamp(mouseX / trackWidth, 0, 1)
    sliderBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
    waitTime = minWait + (percentage * (maxWait - minWait))
    valueLabel.Text = string.format("Wait Time: %.2fs", waitTime)
end

sliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSliding = true end
end)
UserInputService.InputChanged:Connect(function(input)
    if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSliding = false end
end)

-- ==========================================
-- 2. 特殊判定付きのテレポートループ処理
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
                    
                    -- 1. まずは「5スタッドより遠い距離にあるLeaf」を探してリストに入れる
                    for _, child in ipairs(leaves) do
                        if child.Name == "Leaf" and child:IsA("BasePart") then
                            if (child.Position - rootPart.Position).Magnitude > 5 then
                                table.insert(validLeaves, child)
                            end
                        end
                    end
                    
                    -- 2. もし5スタッド以上のLeafが1個もなかったら、「0スタッド以上（全部）」を対象にする
                    if #validLeaves == 0 then
                        for _, child in ipairs(leaves) do
                            if child.Name == "Leaf" and child:IsA("BasePart") then
                                if (child.Position - rootPart.Position).Magnitude >= 0 then
                                    table.insert(validLeaves, child)
                                end
                            end
                        end
                    end
                    
                    -- 3. リストに対象のLeafが存在すれば、最大20個テレポートさせる
                    if #validLeaves > 0 then
                        local teleportedCount = 0
                        for _, leaf in ipairs(validLeaves) do
                            leaf.CFrame = rootPart.CFrame * CFrame.new(0, -2.6, 0)
                            teleportedCount = teleportedCount + 1
                            if teleportedCount >= 20 then
                                break
                            end
                        end
                    else
                        -- 4. フォルダー内に対象のLeafが完全に1個も存在しなくなった場合、指定座標に自分をtp
                        rootPart.CFrame = CFrame.new(escapePosition)
                    end
                end
            end
        end
    end
end)

-- ボタンのON/OFF切り替え
toggleButton.MouseButton1Click:Connect(function()
    isLoopActive = not isLoopActive
    if isLoopActive then
        toggleButton.Text = "Status: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    else
        toggleButton.Text = "Status: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)
