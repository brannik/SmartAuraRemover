-- Create a frame for event handling
local frame = CreateFrame("Frame")

-- Function to build a list of all auras the player has
local function BuildAuraList()
    local auraList = {}
    for i = 1, 40 do
        local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura("player", i)
        if not name then break end
        table.insert(auraList, { id = spellId, index = i })
        --print("Player has aura:", name, "with ID:", spellId, "at index:", i)
    end
    return auraList
end

-- Function to cancel specific auras
local function RemoveAuras()
    --print("Starting to remove auras...")
    local auraList = BuildAuraList()
    local foundAura = false
    -- Iterate through the player's auras
    for _, playerAura in ipairs(auraList) do
        -- Check if the aura is in the BDW_TRINKET_AURAS list
        for _, aura in ipairs(BDW_TRINKET_AURAS) do
            if playerAura.id == aura.id then
                --print("Found matching aura:", playerAura.id, "with aura in list", aura.id, "at position", playerAura.index)
                CancelUnitBuff("player", playerAura.index)
                --UIErrorsFrame:AddMessage("Removed BDW trinket aura: " .. aura.name, 1.0, 1.0, 0.0, 53, 5)
                --print("Removed BDW trinket aura:", aura.name)
                foundAura = true
                break
            end
        end
        if foundAura then break end
    end
    if not foundAura then
        --print("No matching auras found.")
        --UIErrorsFrame:AddMessage("No matching auras found.", 1.0, 0.0, 0.0, 53, 5)
    end
    --print("Finished removing auras.")
end

-- Function to create the help GUI
local function ShowHelpGUI()
    local helpFrame = CreateFrame("Frame", "SmartAuraRemoverHelpFrame", UIParent)
    helpFrame:SetSize(600, 250)
    helpFrame:SetPoint("CENTER", UIParent, "CENTER")
    helpFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    helpFrame:SetBackdropColor(0, 0, 0, 1)

    helpFrame.title = helpFrame:CreateFontString(nil, "OVERLAY")
    helpFrame.title:SetFontObject("GameFontHighlightLarge")
    helpFrame.title:SetPoint("TOP", helpFrame, "TOP", 0, -10)
    helpFrame.title:SetText("Smart Aura Remover Help")

    helpFrame.subtitle = helpFrame:CreateFontString(nil, "OVERLAY")
    helpFrame.subtitle:SetFontObject("GameFontHighlight")
    helpFrame.subtitle:SetPoint("TOP", helpFrame.title, "BOTTOM", 0, -10)
    helpFrame.subtitle:SetText("Make the farming with DBW trinket fun again. Remove the following auras from DBW.\nYou can create macro with the commands below.")

    helpFrame.text = helpFrame:CreateFontString(nil, "OVERLAY")
    helpFrame.text:SetFontObject("GameFontHighlight")
    helpFrame.text:SetPoint("TOPLEFT", helpFrame.subtitle, "BOTTOMLEFT", 10, -10)
    helpFrame.text:SetPoint("BOTTOMRIGHT", helpFrame, "BOTTOMRIGHT", -10, -40)
    helpFrame.text:SetJustifyH("LEFT")
    helpFrame.text:SetJustifyV("TOP")
    helpFrame.text:SetText("Usage:\n|cff00ff00/sar|r |cff0000ff<ground mount>|r#|cff0000ff<flying mount>|r\n\nExample:\n|cff00ff00/sar|r Swift Brown Steed#Swift Green Wind Rider\n\nAdditional Commands:\n|cff00ff00/sar help|r - Display this help window")

    local closeButton = CreateFrame("Button", nil, helpFrame, "UIPanelButtonTemplate")
    closeButton:SetSize(80, 22)
    closeButton:SetPoint("BOTTOM", helpFrame, "BOTTOM", 0, 10)
    closeButton:SetText("Close")
    closeButton:SetScript("OnClick", function()
        helpFrame:Hide()
    end)

    helpFrame:Show()
end

-- Register slash command
SLASH_SMARTAURAREMOVER1 = "/sar"
SlashCmdList["SMARTAURAREMOVER"] = function(msg)
    if msg == "help" then
        ShowHelpGUI()
        return
    end

    if InCombatLockdown() then
        UIErrorsFrame:AddMessage("Cannot use this command in combat.", 1.0, 0.0, 0.0, 53, 5)
        return
    end

    local groundMount, flyingMount = strsplit("#", msg, 2)
    if (not groundMount or groundMount == "") or (not flyingMount or flyingMount == "") then
        UIErrorsFrame:AddMessage("Please specify both ground and flying mounts. Use /sar help for more information.", 1.0, 0.0, 0.0, 53, 5)
        return
    end

    --UIErrorsFrame:AddMessage("Smart Aura Remover command triggered", 0.0, 1.0, 0.0, 53, 5)
    RemoveAuras()

    -- Determine which mount to cast based on the player's location
    if IsFlyableArea() and flyingMount then
        CastSpellByName(flyingMount)
        --UIErrorsFrame:AddMessage("Casting flying mount: " .. flyingMount, 0.0, 1.0, 0.0, 53, 5)
    else
        CastSpellByName(groundMount)
        --UIErrorsFrame:AddMessage("Casting ground mount: " .. groundMount, 0.0, 1.0, 0.0, 53, 5)
    end
end

-- Helper function to check if a spell is a mount spell
function IsMountedSpell(spellID)
    local _, _, _, _, _, _, mountID = C_MountJournal.GetMountInfoBySpellID(spellID)
    return mountID ~= nil
end
