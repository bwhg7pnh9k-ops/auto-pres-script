-- ========== БЫСТРЫЙ СТАРТ ==========
local startTime = tick()
print("Initializing...")

-- Минимальные задержки
local function quickWait(seconds)
    task.wait(seconds or 0.001)
end

-- Быстрая проверка загрузки
local function waitForGame()
    while not game:IsLoaded() do quickWait() end
    while not game.Players.LocalPlayer do quickWait() end
    while not game.Players.LocalPlayer.Character do quickWait() end
end

waitForGame()
print("Game loaded in: " .. string.format("%.2f", tick() - startTime) .. " seconds")

-- ========== НАСТРОЙКИ (ОПТИМИЗИРОВАННЫЕ) ==========
getgenv().standList =  {
    ["The World"] = true,
    ["Star Platinum"] = true,
    ["Star Platinum: The World"] = true,
    ["Crazy Diamond"] = true,
    ["King Crimson"] = true,
    ["King Crimson Requiem"] = true
}
getgenv().waitUntilCollect = 0.1 -- МИНИМАЛЬНАЯ ЗАДЕРЖКА (было 0.6)
getgenv().sortOrder = "Asc"
getgenv().lessPing = false
getgenv().autoRequiem = true
getgenv().NPCTimeOut = 5 -- Уменьшено с 15 до 5
getgenv().HamonCharge = 90
getgenv().webhook = "https://discord.com/api/webhooks/1381173563612074085/mSPyu9_6PXn2TwNIzairPJqHnRgORN-YUGQNaj2h-f3ZMWLRxck9TCKdxbDIx6oejUOq"

-- ========== СИСТЕМА ЛОГИРОВАНИЯ ==========
local function debugLog(message, level)
    level = level or "INFO"
    print(string.format("[%s] [%s] %s", os.date("%H:%M:%S"), level, message))
end

debugLog("Script started", "SUCCESS")

-- ========== БЫСТРАЯ ОБРАБОТКА ОШИБОК ==========
game:GetService("CoreGui").DescendantAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        local GrabError = child:FindFirstChild("ErrorMessage", true)
        repeat quickWait() until GrabError and GrabError.Text ~= "Label"
        local Reason = GrabError and GrabError.Text or ""
        if Reason:match("kick") or Reason:match("You") or Reason:match("conn") or Reason:match("rejoin") then
            debugLog("Error detected: " .. Reason, "ERROR")
            game:GetService("TeleportService"):Teleport(2809202155, game:GetService("Players").LocalPlayer)
        end
    end
end)

local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character

-- ========== БЫСТРАЯ ПРОВЕРКА КОМПОНЕНТОВ ==========
local function waitForChildSafe(parent, name, timeout)
    timeout = timeout or 2
    local start = tick()
    while not parent:FindFirstChild(name) and tick() - start < timeout do
        quickWait()
    end
    return parent:FindFirstChild(name)
end

repeat quickWait() until waitForChildSafe(Character, "RemoteEvent") and waitForChildSafe(Character, "RemoteFunction")

local RemoteFunction, RemoteEvent = Character.RemoteFunction, Character.RemoteEvent
local HRP = Character.PrimaryPart
local part
local dontTPOnDeath = true

-- ========== БЫСТРАЯ ПРОВЕРКА УРОВНЯ ==========
if LocalPlayer.PlayerStats.Level.Value == 50 then 
    debugLog("Level 50 reached, stopping", "WARNING")
    while true do 
        quickWait(9999999) 
    end 
end

-- ========== МГНОВЕННОЕ СОЗДАНИЕ HUD ==========
if not LocalPlayer.PlayerGui:FindFirstChild("HUD") then
    debugLog("Creating HUD", "INFO")
    local HUD = game:GetService("ReplicatedStorage").Objects.HUD:Clone()
    HUD.Parent = LocalPlayer.PlayerGui
end

debugLog("Starting game...", "INFO")
RemoteEvent:FireServer("PressedPlay")
quickWait(0.5) -- Уменьшено с 5 до 0.5

-- ========== МГНОВЕННАЯ ОЧИСТКА ЭКРАНОВ ==========
task.spawn(function()
    for _, screenName in pairs({"LoadingScreen1", "LoadingScreen"}) do
        local screen = LocalPlayer.PlayerGui:FindFirstChild(screenName)
        if screen then 
            screen:Destroy()
            debugLog("Removed: " .. screenName, "INFO")
        end
    end
end)

-- ========== БЫСТРОЕ УДАЛЕНИЕ ЭФФЕКТОВ ==========
task.spawn(function()
    local dof = game.Lighting:FindFirstChild("DepthOfField")
    if dof then 
        dof:Destroy()
        debugLog("Depth of field removed", "INFO")
    end
end)

-- ========== ДАННЫЕ (БЫСТРАЯ ЗАГРУЗКА) ==========
local Data = {}
local fileExists, result = pcall(function()
    return game:GetService('HttpService'):JSONDecode(readfile("AutoPres3_"..LocalPlayer.Name..".txt"))
end)

if fileExists and result then
    Data = result
    debugLog("Data loaded from file", "INFO")
else
    Data = {
        ["Time"] = tick(),
        ["Prestige"] = LocalPlayer.PlayerStats.Prestige.Value,
        ["Level"] = LocalPlayer.PlayerStats.Level.Value
    }
    writefile("AutoPres3_"..LocalPlayer.Name..".txt", game:GetService('HttpService'):JSONEncode(Data))
    debugLog("Data file created", "INFO")
end

local lastTick = tick()

-- ========== ХУКИ ==========
local itemHook;
itemHook = hookfunction(getrawmetatable(game.Players.LocalPlayer.Character.HumanoidRootPart.Position).__index, function(p,i)
    if getcallingscript().Name == "ItemSpawn" and i:lower() == "magnitude" then
        return 0
    end
    return itemHook(p,i)
end)

local Hook;
Hook = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
    local args = {...}
    local namecallmethod =  getnamecallmethod()

    if namecallmethod == "InvokeServer" then
        if args[1] == "idklolbrah2de" then
            return "  ___XP DE KEY"
        end
    end

    return Hook(self, ...)
end))

-- ========== СИСТЕМА СМЕНЫ СЕРВЕРОВ (ОПТИМИЗИРОВАННАЯ) ==========
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour

local function TPReturner()
    local Site;
    if foundAnything == "" then
       Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' .. getgenv().sortOrder .. '&limit=100'))
    else
       Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' .. getgenv().sortOrder .. '&limit=100&cursor=' .. foundAnything))
    end

    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
       foundAnything = Site.nextPageCursor
    end

    local num = 0;
    for _,v in pairs(Site.data) do
       local Possible = true
       ID = tostring(v.id)
       if tonumber(v.maxPlayers) > tonumber(v.playing) then
          for _,Existing in pairs(AllIDs) do
             if num ~= 0 then
                if ID == tostring(Existing) then
                   Possible = false
                end
             else
                if tonumber(actualHour) ~= tonumber(Existing) then
                   local delFile = pcall(function()
                   delfile("XenonAutoPres3ServerBlocker.json")
                   AllIDs = {}
                   table.insert(AllIDs, actualHour)
                   end)
                end
             end
             num = num + 1
          end
          if Possible == true then
             table.insert(AllIDs, ID)
             quickWait()
             pcall(function()
                writefile("XenonAutoPres3ServerBlocker.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                quickWait()
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
             end)
             quickWait(0.5)
          end
       end
    end
 end

 local function Teleport()
    while quickWait() do
       pcall(function()
        if getgenv().lessPing then
            game:GetService("TeleportService"):Teleport(2809202155, game:GetService("Players").LocalPlayer)
     
            game:GetService("TeleportService").TeleportInitFailed:Connect(function()
                 game:GetService("TeleportService"):Teleport(2809202155, game:GetService("Players").LocalPlayer)
            end)
            
            repeat quickWait() until game.JobId ~= game.JobId
        end

       TPReturner()
       if foundAnything ~= "" then
          TPReturner()
       end
       end)
    end
 end

-- ========== БЕЗОПАСНАЯ ЧАСТЬ ДЛЯ ТЕЛЕПОРТА ==========
part = Instance.new("Part")
part.Parent = workspace
part.Anchored = true
part.Size = Vector3.new(25,1,25)
part.Position = Vector3.new(500, 2000, 500)

-- ========== СИСТЕМА ПОИСКА ПРЕДМЕТОВ ==========
local function findItem(itemName)
    local ItemsDict = {
        ["Position"] = {},
        ["ProximityPrompt"] = {},
        ["Items"] = {}
    }

    for _,item in pairs(game:GetService("Workspace")["Item_Spawns"].Items:GetChildren()) do
        if item:FindFirstChild("MeshPart") and item.ProximityPrompt.ObjectText == itemName then
            if item.ProximityPrompt.MaxActivationDistance == 8 then
                table.insert(ItemsDict["Items"], item.ProximityPrompt.ObjectText)
                table.insert(ItemsDict["ProximityPrompt"], item.ProximityPrompt)
                table.insert(ItemsDict["Position"], item.MeshPart.CFrame)
            end
        end
    end
    return ItemsDict
end

local function countItems(itemName)
    local itemAmount = 0

    for _,item in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if item.Name == itemName then
            itemAmount += 1;
        end
    end

    return itemAmount
end

local function useItem(aItem, amount)
    quickWait()
    local item = LocalPlayer.Backpack:WaitForChild(aItem, 3) -- Уменьшено с 5 до 3

    if not item then
        debugLog("Item not found: " .. aItem, "WARNING")
        Teleport()
        return
    end

    quickWait(0.05) -- Уменьшено с 0.2 до 0.05
    if amount then
        LocalPlayer.Character.Humanoid:EquipTool(item)
        LocalPlayer.Character:WaitForChild("RemoteFunction"):InvokeServer("LearnSkill",{["Skill"] = "Worthiness",["SkillTreeType"] = "Character"})
        repeat item:Activate() quickWait() until LocalPlayer.PlayerGui:FindFirstChild("DialogueGui")
        quickWait(0.05)
        firesignal(LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
        quickWait(0.05)
        firesignal(LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.Options:WaitForChild("Option1").TextButton.MouseButton1Click)
        quickWait(0.05)
        firesignal(LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
        quickWait(0.05)
	    repeat quickWait() until LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.DialogueFrame.Frame.Line001.Container.Group001.Text == "You"
        quickWait(0.05)
	    firesignal(LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
        quickWait(0.05)
    end
end

local function attemptStandFarm()
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        debugLog("Invalid LocalPlayer or Character", "ERROR")
        return
    end
    
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2010, 500)
    
    if LocalPlayer.PlayerStats and LocalPlayer.PlayerStats.Stand and LocalPlayer.PlayerStats.Stand.Value == "None" then
        debugLog("Attempting to get stand with Mysterious Arrow", "INFO")
        useItem("Mysterious Arrow", "II")
        
        repeat quickWait(0.1) until LocalPlayer.PlayerStats.Stand.Value ~= "None"
        
        if not getgenv().standList or not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            debugLog("Bad stand, using Rokakaka", "INFO")
            useItem("Rokakaka", "II")
        elseif getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            dontTPOnDeath = true
            debugLog("Good stand obtained: " .. LocalPlayer.PlayerStats.Stand.Value, "SUCCESS")
            Teleport()
        end

    elseif LocalPlayer.PlayerStats and LocalPlayer.PlayerStats.Stand and LocalPlayer.PlayerStats.Stand.Value ~= "None" then
        if not getgenv().standList or not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            debugLog("Bad stand, using Rokakaka", "INFO")
            useItem("Rokakaka", "II")
        end
    end
end

local function getitem(item, itemIndex)
    local gotItem = false
    local timeout = getgenv().waitUntilCollect + 3 -- Уменьшено с 5 до 3

    if Character:FindFirstChild("SummonedStand") then
        if Character:FindFirstChild("SummonedStand").Value then
            RemoteFunction:InvokeServer("ToggleStand", "Toggle")
        end
    end

    LocalPlayer.Backpack.ChildAdded:Connect(function()
        gotItem = true
    end)
    
    task.spawn(function()
        while not gotItem do
            quickWait()
            if item and item["Position"] and item["Position"][itemIndex] then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = item["Position"][itemIndex] - Vector3.new(0,10,0)
            end
        end
    end)

    quickWait(getgenv().waitUntilCollect)

    task.spawn(function()
        if item and item["ProximityPrompt"] and item["ProximityPrompt"][itemIndex] then
            fireproximityprompt(item["ProximityPrompt"][itemIndex])
        end
        
        local screenGui = LocalPlayer.PlayerGui:WaitForChild("ScreenGui", 3) -- Уменьшено с 5 до 3
        
        if not screenGui then
            return
        end

        local screenGuiPart = screenGui:WaitForChild("Part")
        for _, button in pairs(screenGuiPart:GetDescendants()) do
            if button:FindFirstChild("Part") then
                if button:IsA("ImageButton") and button:WaitForChild("Part").TextColor3 == Color3.new(0, 1, 0) then
                    repeat
                        firesignal(button.MouseEnter)
                        firesignal(button.MouseButton1Up)
                        firesignal(button.MouseButton1Click)
                        firesignal(button.Activated)
                        quickWait()
                    until not LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
                end
            end
        end
    end)
    
    task.spawn(function()
        for i=timeout, 1, -1 do
            quickWait(1)
        end

        if not gotItem then
            gotItem = true
            return
        end
    end)

    while not gotItem do
        quickWait()
    end
end

local function farmItem(itemName, amount)
    local items = findItem(itemName)
    local amountFirst = countItems(itemName) == amount

    for itemIndex, _ in pairs(items["Position"]) do
        if countItems(itemName) == amount or amountFirst then
            break
        else
            getitem(items, itemIndex)
        end
    end
    
    return true
end

local function endDialogue(NPC, Dialogue, Option)
    local dialogueToEnd = {
        ["NPC"] = NPC,
        ["Dialogue"] = Dialogue,
        ["Option"] = Option
     }
    RemoteEvent:FireServer("EndDialogue", dialogueToEnd)
end

local function storyDialogue()
    local Quest =
    {
    ["Storyline"] = {"#1", "#1", "#1", "#2", "#3", "#3", "#3", "#4", "#5", "#6", "#7", "#8", "#9", "#10", "#11", "#11", "#12", "#14"},
    ["Dialogue"] = {"Dialogue2", "Dialogue6", "Dialogue6", "Dialogue3", "Dialogue3", "Dialogue3", "Dialogue6", "Dialogue3", "Dialogue5", "Dialogue5", "Dialogue5", "Dialogue4", "Dialogue7", "Dialogue6", "Dialogue8", "Dialogue11", "Dialogue3", "Dialogue2"}
    }
    
    for counter = 1, 18, 1 do
       RemoteEvent:FireServer("EndDialogue", {["NPC"] = "Storyline".. " " .. Quest["Storyline"][counter],["Dialogue"] = Quest["Dialogue"][counter],["Option"] = "Option1"})
    end
end

-- ========== УЛУЧШЕННАЯ ФУНКЦИЯ KILLNPC ==========
local function killNPC(npcName, playerDistance, dontDestroyOnKill, extraParameters)
    debugLog("Starting killNPC for: " .. npcName, "INFO")
    
    local NPC = workspace.Living:FindFirstChild(npcName)
    if not NPC then
        debugLog("NPC not found: " .. npcName, "WARNING")
        Teleport()
        return false
    end
    
    local beingTargeted = true
    local doneKilled = false
    local killTimeout = os.time() + 30 -- Уменьшено с 45 до 30
    local deadCheck = nil
    
    -- БЕЗОПАСНАЯ ОБЕРТКА ДЛЯ ДОПОЛНИТЕЛЬНЫХ ПАРАМЕТРОВ
    local function safeExtraParameters()
        if extraParameters then
            local success, err = pcall(extraParameters)
            if not success then
                debugLog("Error in extraParameters: " .. tostring(err), "ERROR")
            end
        end
    end
    
    -- БЕЗОПАСНАЯ УСТАНОВКА ПОЗИЦИИ СТЕНДА
    local function setStandMorphPosition()
        pcall(function()
            if not NPC or not NPC.Parent then return end
            
            if LocalPlayer.PlayerStats.Stand.Value == "None" then
                if HRP then
                    HRP.CFrame = NPC.HumanoidRootPart.CFrame - Vector3.new(0, 5, 0)
                end
                return
            end

            if not Character:FindFirstChild("SummonedStand") or not Character.SummonedStand.Value or not Character:FindFirstChild("StandMorph") then
                RemoteFunction:InvokeServer("ToggleStand", "Toggle")
                return
            end

            if Character.StandMorph and Character.StandMorph:FindFirstChild("PrimaryPart") and NPC and NPC:FindFirstChild("HumanoidRootPart") then
                Character.StandMorph.PrimaryPart.CFrame = NPC.HumanoidRootPart.CFrame + NPC.HumanoidRootPart.CFrame.lookVector * -1.1
                if HRP then
                    HRP.CFrame = Character.StandMorph.PrimaryPart.CFrame + Character.StandMorph.PrimaryPart.CFrame.lookVector - Vector3.new(0, playerDistance or 15, 0)
                end
            end
            
            if not Character:FindFirstChild("FocusCam") then
                local FocusCam = Instance.new("ObjectValue", Character)
                FocusCam.Name = "FocusCam"
                if Character.StandMorph and Character.StandMorph:FindFirstChild("PrimaryPart") then
                    FocusCam.Value = Character.StandMorph.PrimaryPart
                end
            end
            
            if Character:FindFirstChild("FocusCam") and Character.FocusCam.Value ~= Character.StandMorph.PrimaryPart then
                if Character.StandMorph and Character.StandMorph:FindFirstChild("PrimaryPart") then
                    Character.FocusCam.Value = Character.StandMorph.PrimaryPart
                end
            end
        end)
    end

    local function HamonCharge()
        pcall(function()
            if not Character:FindFirstChild("Hamon") then
                return
            end

            if Character.Hamon.Value <= getgenv().HamonCharge then
                RemoteFunction:InvokeServer("AssignSkillKey", {["Type"] = "Spec",["Key"] = "Enum.KeyCode.L",["Skill"] = "Hamon Breathing"})
                Character.RemoteEvent:FireServer("InputBegan", {["Input"] = Enum.KeyCode.L})
            end
        end)
    end

    local function BlockBreaker()
        pcall(function()
            if not NPC or not NPC.Parent then
                return
            end
        
            if game:GetService("CollectionService"):HasTag(NPC, "Blocking") then
                RemoteEvent:FireServer("InputBegan", {["Input"] = Enum.KeyCode.R})
            elseif NPC.Humanoid.Health <= 1 then
                task.spawn(function()
                    quickWait(3) -- Уменьшено с 5 до 3
                    pcall(function()
                        if NPC and NPC.Parent then
                            RemoteFunction:InvokeServer("Attack", "m1")
                        end
                    end)
                end)
            elseif NPC.Humanoid.Health >= 1 then
                RemoteFunction:InvokeServer("Attack", "m1")
            end
        end)
    end

    -- ОБНАРУЖЕНИЕ СМЕРТИ
    deadCheck = LocalPlayer.PlayerGui.HUD.Main.DropMoney.Money.ChildAdded:Connect(function(child)
        local number = tonumber(string.match(child.Name,"%d+"))
        if number and NPC and NPC.Parent then
            doneKilled = true
            debugLog("NPC killed: " .. npcName, "SUCCESS")
            deadCheck:Disconnect()
            if not dontDestroyOnKill then
                pcall(function()
                    NPC:Destroy()
                end)
            end
        end
    end)

    -- ОСНОВНОЙ ЦИКЛ УБИЙСТВА С ТАЙМАУТОМ
    while beingTargeted and os.time() < killTimeout do
        quickWait(0.05) -- Уменьшено с 0.1 до 0.05
        
        -- ПРОВЕРКА СУЩЕСТВОВАНИЯ NPC
        local npcExists = pcall(function()
            return NPC and NPC.Parent and NPC:FindFirstChild("HumanoidRootPart")
        end)
        
        if not npcExists or not NPC or not NPC.Parent then
            debugLog("NPC disappeared: " .. npcName, "WARNING")
            if deadCheck then
                deadCheck:Disconnect()
            end
            beingTargeted = false
            break
        end
        
        -- ВЫПОЛНЕНИЕ ЗАДАЧ С БЕЗОПАСНОСТЬЮ
        task.spawn(safeExtraParameters)
        task.spawn(setStandMorphPosition)
        task.spawn(HamonCharge)
        task.spawn(BlockBreaker)
        
        -- ПРОВЕРКА УБИЙСТВА
        if doneKilled then
            beingTargeted = false
            break
        end
    end
    
    -- ОБРАБОТКА ТАЙМАУТА
    if os.time() >= killTimeout and not doneKilled then
        debugLog("Kill timeout for: " .. npcName, "WARNING")
        if deadCheck then
            deadCheck:Disconnect()
        end
        Teleport()
        return false
    end
    
    debugLog("killNPC completed for: " .. npcName .. ", killed: " .. tostring(doneKilled), "INFO")
    return doneKilled
end

-- ========== ФУНКЦИИ ДЛЯ ВАМПИРОВ ==========
local function moveToVampire()
    pcall(function()
        local vampireNPC = workspace.Living:FindFirstChild("Vampire")
        if not vampireNPC then
            return
        end
        
        local rootPart = vampireNPC:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            return
        end
        
        if not Character or not Character:FindFirstChild("PrimaryPart") then
            return
        end
        
        Character.PrimaryPart.CFrame = rootPart.CFrame - Vector3.new(0, 15, 0)
    end)
end

local function checkVampireQuest()
    pcall(function()
        local questPanel = LocalPlayer.PlayerGui.HUD.Main.Frames.Quest.Quests
        if not questPanel:FindFirstChild("Take down 3 vampires") then
            if (tick() - lastTick) >= 3 then -- Уменьшено с 5 до 3
                lastTick = tick()
                endDialogue("William Zeppeli", "Dialogue4", "Option1")
            end
        end
    end)
end

local function checkPrestige(level, prestige)
    if (level == 35 and prestige == 0) or (level == 40 and prestige == 1) or (level == 45 and prestige == 2) then
        endDialogue("Prestige", "Dialogue2", "Option1")
        return true
    else
        return false
    end
end

local function allocateSkills()
    task.spawn(function()
        pcall(function()
            RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power V",["SkillTreeType"] = "Stand"})
            RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power IV",["SkillTreeType"] = "Stand"})
            RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power III",["SkillTreeType"] = "Stand"})
            RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power II",["SkillTreeType"] = "Stand"})
            RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power I",["SkillTreeType"] = "Stand"})
            
            if LocalPlayer.PlayerStats.Spec.Value == "Hamon (William Zeppeli)" then
                RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Hamon Punch III",["SkillTreeType"] = "Spec"})
                RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Lung Capacity III", ["SkillTreeType"] = "Spec"})
                RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Breathing Technique III",["SkillTreeType"] = "Spec"})
            end
        end)
    end)
end

-- ========== УЛУЧШЕННАЯ ФУНКЦИЯ AUTOSTORY ==========
local function autoStory()
    debugLog("AutoStory started", "INFO")
    
    local questPanel = LocalPlayer.PlayerGui.HUD.Main.Frames.Quest.Quests
    local repeatCount = 0
    allocateSkills()

    -- REQUIEM CHECK
    if LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Prestige.Value >= 1 and LocalPlayer.Backpack:FindFirstChild("Requiem Arrow") and (LocalPlayer.PlayerStats.Stand.Value == "King Crimson" or LocalPlayer.PlayerStats.Stand.Value == "Star Platinum") then
        debugLog("Using Requiem Arrow", "INFO")
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2010, 500)
        local oldStand = LocalPlayer.PlayerStats.Stand.Value
        useItem("Requiem Arrow", "V")
        repeat quickWait() until LocalPlayer.PlayerStats.Stand.Value ~= oldStand
        autoStory()
        return
    end

    -- HAMON ACQUISITION
    if LocalPlayer.PlayerStats.Spec.Value == "None" and LocalPlayer.PlayerStats.Level.Value >= 25 then
        local function collectAndSell(toolName, amount)
            pcall(function()
                farmItem(toolName, amount)
                if LocalPlayer.Backpack:FindFirstChild(toolName) then
                    Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(toolName))
                    endDialogue("Merchant", "Dialogue5", "Option2")
                end
            end)
        end
        
        if not LocalPlayer.Backpack:FindFirstChild("Zeppeli's Hat") then
            farmItem("Zeppeli's Hat", 1)
        end

        if LocalPlayer.PlayerStats.Money.Value <= 10000 then
            debugLog("Farming money for Hamon", "INFO")
            collectAndSell("Mysterious Arrow", 25)
            collectAndSell("Rokakaka", 25)
            collectAndSell("Diamond", 10)
            collectAndSell("Steel Ball", 10)
            collectAndSell("Quinton's Glove", 10)
            collectAndSell("Pure Rokakaka", 10)
            collectAndSell("Ribcage Of The Saint's Corpse", 10)
            collectAndSell("Ancient Scroll", 10)
            collectAndSell("Clackers", 10)
            collectAndSell("Caesar's headband", 10)
        end

        if LocalPlayer.Backpack:FindFirstChild("Zeppeli's Hat") then
            debugLog("Getting Hamon from Lisa Lisa", "INFO")
            Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("Zeppeli's Hat"))
            game.Players.LocalPlayer.Character.RemoteEvent:FireServer("PromptTriggered", game.ReplicatedStorage.NewDialogue:FindFirstChild("Lisa Lisa"))
            
            repeat
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,8,0, true, nil, 1)
                quickWait(0.02)
            until game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui")
            
            if game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui") then
                repeat
                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,8,0, true, nil, 1)
                    quickWait(0.02)
                until game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1")
            end
            
            firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options.Option1.TextButton.MouseButton1Click)
            
            repeat
                firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
                quickWait(0.02)
            until game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1")
            
            if game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1") then
                firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options.Option1.TextButton.MouseButton1Click)
            end
            
            repeat
                firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
                quickWait(0.02)
            until game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1")
            
            if game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1") then
                firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options.Option1.TextButton.MouseButton1Click)
            end
            
            quickWait(5) -- Уменьшено с 10 до 5
            autoStory()
        else
            Teleport()
        end
        return
    end
        
    -- GET QUESTS
    while #questPanel:GetChildren() < 2 and repeatCount < 500 do -- Уменьшено с 1000 до 500
        if not questPanel:FindFirstChild("Take down 3 vampires") then
            lastTick = tick()
            endDialogue("William Zeppeli", "Dialogue4", "Option1")
        end
    
        LocalPlayer.QuestsRemoteFunction:InvokeServer({[1] = "ReturnData"})
        storyDialogue()
        quickWait(0.005) -- Уменьшено с 0.01 до 0.005
        repeatCount = repeatCount + 1
    end

    if repeatCount >= 500 then
        debugLog("Quest timeout, teleporting", "WARNING")
        Teleport()
        return
    end

    -- ========== ОБРАБОТКА КВЕСТОВ ==========
    
    -- SECURITY GUARD
    if questPanel:FindFirstChild("Help Giorno by Defeating Security Guards") then
        debugLog("Killing Security Guard", "INFO")
        if killNPC("Security Guard", 15) then
            quickWait(0.5)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end
        return

    -- NO STAND / BAD STAND
    elseif not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] and LocalPlayer.PlayerStats.Level.Value >= 3 and dontTPOnDeath then
        debugLog("No stand or bad stand, farming", "INFO")
        quickWait(2) -- Уменьшено с 5 до 2
    
        farmItem("Rokakaka", 25)
        farmItem("Mysterious Arrow", 25)
        farmItem("Zeppeli's Hat", 1)

        if countItems("Mysterious Arrow") >= 25 and countItems("Rokakaka") >= 25 then
            debugLog("Attempting stand farm", "INFO")
            dontTPOnDeath = false
            attemptStandFarm()
        else
            Teleport()
        end
        return

    -- LEAKY EYE LUCA
    elseif questPanel:FindFirstChild("Defeat Leaky Eye Luca") and getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
        debugLog("Killing Leaky Eye Luca", "INFO")
        if killNPC("Leaky Eye Luca", 15) then
            quickWait(0.5)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end
        return

    -- BUCCIARATI
    elseif questPanel:FindFirstChild("Defeat Bucciarati") then
        debugLog("Killing Bucciarati", "INFO")
        if killNPC("Bucciarati", 15) then
            quickWait(0.5)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end
        return

    -- MONEY QUEST
    elseif questPanel:FindFirstChild("Collect $5,000 To Cover For Popo's Real Fortune") then
        debugLog("Collecting money for Popo", "INFO")
        if LocalPlayer.PlayerStats.Money.Value < 5000 then
            local function collectAndSell(toolName, amount)
                pcall(function()
                    if countItems(toolName) <= amount then
                        farmItem(toolName, amount)
                        if LocalPlayer.Backpack:FindFirstChild(toolName) then
                            Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(toolName))
                            endDialogue("Merchant", "Dialogue5", "Option2")
                            storyDialogue()
                            autoStory()
                        end
                    end
                end)
            end
            
            quickWait(5) -- Уменьшено с 10 до 5
            collectAndSell("Mysterious Arrow", 25)
            collectAndSell("Rokakaka", 25)
            collectAndSell("Diamond", 10)
            collectAndSell("Steel Ball", 10)
            collectAndSell("Quinton's Glove", 10)
            collectAndSell("Pure Rokakaka", 10)
            collectAndSell("Ribcage Of The Saint's Corpse", 10)
            collectAndSell("Ancient Scroll", 10)
            collectAndSell("Clackers", 10)
            collectAndSell("Caesar's headband", 10)
        end
        autoStory()
        return

    -- FUGO
    elseif questPanel:FindFirstChild("Defeat Fugo And His Purple Haze") then
        debugLog("Killing Fugo", "INFO")
        if killNPC("Fugo", 15) then
            quickWait(0.5)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end
        return

    -- PESCI
    elseif questPanel:FindFirstChild("Defeat Pesci") then
        debugLog("Killing Pesci", "INFO")
        if killNPC("Pesci", 15) then
            quickWait(0.5)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end
        return

    -- GHIACCIO
    elseif questPanel:FindFirstChild("Defeat Ghiaccio") then
        debugLog("Killing Ghiaccio", "INFO")
        if killNPC("Ghiaccio", 15) then
            quickWait(0.5)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end
        return

    -- DIAVOLO
    elseif questPanel:FindFirstChild("Defeat Diavolo") then
        debugLog("Killing Diavolo", "INFO")
        if killNPC("Diavolo", 15) then
            endDialogue("Storyline #14", "Dialogue7", "Option1")
            if Character:WaitForChild("Requiem Arrow", 3) then -- Уменьшено с 5 до 3
                Character.Humanoid.Health = 0
                Teleport()
            else
                autoStory()
            end
        else
            autoStory()
        end
        return

    -- ========== VAMPIRE QUEST (FIXED AND OPTIMIZED) ==========
    elseif questPanel:FindFirstChild("Take down 3 vampires") and LocalPlayer.PlayerStats.Spec.Value ~= "None" and LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Level.Value ~= 50 then
        debugLog("Starting Vampire quest", "INFO")
        
        getgenv().HamonCharge = 10
        local vampireKillAttempts = 0
        local maxAttempts = 2 -- Уменьшено с 3 до 2
        
        -- KILL VAMPIRES WITH RETRY LOGIC
        while vampireKillAttempts < maxAttempts do
            vampireKillAttempts = vampireKillAttempts + 1
            debugLog("Vampire kill attempt " .. vampireKillAttempts .. "/" .. maxAttempts, "INFO")
            
            -- CREATE VAMPIRE TASK FUNCTION
            local vampireTasks = function()
                moveToVampire()
                checkVampireQuest()
            end
            
            -- ATTEMPT KILL
            local success = killNPC("Vampire", 15, false, vampireTasks)
            
            if success then
                debugLog("Vampire killed successfully", "SUCCESS")
                quickWait(0.5)
                storyDialogue()
                autoStory()
                return
            else
                debugLog("Vampire kill failed, retrying...", "WARNING")
                quickWait(1) -- Уменьшено с 2 до 1
            end
        end
        
        -- IF ALL ATTEMPTS FAIL
        debugLog("All vampire kill attempts failed, teleporting", "ERROR")
        Teleport()
        return

    -- LEVEL 50 CHECK
    elseif LocalPlayer.PlayerStats.Level.Value == 50 then
        debugLog("Level 50 reached", "INFO")
        if Character:FindFirstChild("FocusCam") then
            Character.FocusCam:Destroy()
            pcall(function()
                delfile("AutoPres3_"..LocalPlayer.Name..".txt")
            end)
        end
        return
    end
    
    debugLog("AutoStory completed or no matching quest", "INFO")
end

-- ========== ПРОВЕРКА ПРЕСТИЖА (ОПТИМИЗИРОВАННАЯ) ==========
task.spawn(function()
    while quickWait(2) do -- Уменьшено с 3 до 2
        pcall(function()
            if checkPrestige(LocalPlayer.PlayerStats.Level.Value, LocalPlayer.PlayerStats.Prestige.Value) then
                debugLog("Prestige achieved!", "SUCCESS")
                Teleport()
            elseif LocalPlayer.PlayerStats.Level.Value == 50 then
                if Character:FindFirstChild("FocusCam") then
                    Character.FocusCam:Destroy()
                    debugLog("Level 50, destroying FocusCam", "INFO")
                    break
                end
            end
        end)
    end
end)

-- ========== ОБРАБОТЧИК ПОЯВЛЕНИЯ ПЕРСОНАЖА ==========
game.Workspace.Living.ChildAdded:Connect(function(character)
    pcall(function()
        if character.Name == LocalPlayer.Name then
            if LocalPlayer.PlayerStats.Level.Value == 50 then
                debugLog("Level 50, not reconnecting", "INFO")
            else
                if dontTPOnDeath then
                    debugLog("Death detected, teleporting", "WARNING")
                    Teleport()
                else
                    debugLog("Death detected, attempting stand farm", "INFO")
                    attemptStandFarm()
                end
            end
        end
    end)
end)

-- ========== ОБРАБОТЧИК ИЗМЕНЕНИЯ УРОВНЯ ==========
LocalPlayer.PlayerStats.Level:GetPropertyChangedSignal("Value"):Connect(function()
    debugLog("Level changed to: " .. LocalPlayer.PlayerStats.Level.Value, "INFO")
end)

-- ========== NOCLIP (ОПТИМИЗИРОВАННЫЙ) ==========
LocalPlayer.CharacterAdded:Connect(function()
    quickWait(0.5) -- Уменьшено с 1 до 0.5
    pcall(function()
        for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
            if child:IsA("BasePart") and child.CanCollide == true then
                child.CanCollide = false
            end
        end
    end)
end)

-- ========== NOCLIP BYPASS ==========
hookfunction(workspace.Raycast, function()
    return
end)

-- ========== ЗАПУСК СКРИПТА ==========
debugLog("Script initialized in: " .. string.format("%.2f", tick() - startTime) .. " seconds", "SUCCESS")
autoStory()