local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local isLoopActive = false

-- ==========================================
-- 1. GUIの作成（ドラッグ可能・死んでも消えない）
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeafCollectorGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 150, 0, 50)
toggleButton.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 18
toggleButton.Text = "Leaf TP: OFF"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = toggleButton

-- ドラッグ処理
local dragging, dragInput, dragStart, startPos
toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
toggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- 2. テレポートのループ処理（足元に設定）
-- ==========================================
task.spawn(function()
    while true do
        task.wait(1) -- 1秒待機
        
        if isLoopActive then
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                local leavesFolder = Workspace:FindFirstChild("Leaves")
                if leavesFolder then
                    for _, child in ipairs(leavesFolder:GetChildren()) do
                        if child.Name == "Leaf" and child:IsA("BasePart") then
                            -- まだ離れているLeafを1個だけ探す
                            if (child.Position - rootPart.Position).Magnitude > 5 then
                                -- プレイヤーの足元（HumanoidRootPartの真下、Y軸を約3スタッド下げる）にテレポート
                                child.CFrame = rootPart.CFrame * CFrame.new(0, -3, 0)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 3. ボタンのON/OFF切り替え
-- ==========================================
toggleButton.MouseButton1Click:Connect(function()
    isLoopActive = not isLoopActive
    if isLoopActive then
        toggleButton.Text = "Leaf TP: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    else
        toggleButton.Text = "Leaf TP: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)
