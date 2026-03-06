local addonName = ...
local soundIDs = {567504, 567508}

-- Common IDs for Silvershard (Retail, Blitz, Brawl, Rated)
local silvershardIDs = {
    [598] = true,  -- Standard
    [727] = true,  -- Modern/Blitz
    [761] = true,  -- Alternate
    [960] = true   -- Rated
}

local f = CreateFrame("Frame")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

local function RefreshBattlefieldMap()
    -- Ensure map addon is loaded
    if not BattlefieldMapFrame then 
        UIParentLoadAddOn("Blizzard_BattlefieldMap") 
    end

    -- Force the refresh only if the map is open
    if BattlefieldMapFrame and BattlefieldMapFrame:IsShown() then
        BattlefieldMapFrame:Hide()
        BattlefieldMapFrame:Show()
    end
end

local function CheckZone()
    local zoneName, _, _, _, _, _, _, instanceID = GetInstanceInfo()
    
    -- Check if we are in Silvershard via ID OR Name
    local isSilvershard = silvershardIDs[instanceID] or (zoneName == "Silvershard Mines")

    if isSilvershard then
        -- Apply Sound Mutes
        for _, id in ipairs(soundIDs) do
            MuteSoundFile(id)
        end
        
        -- Start 1-second ticker if not running
        if not f.ticker then
            f.ticker = C_Timer.NewTicker(1, RefreshBattlefieldMap)
            print("|cff00ff00Silvershard Fix:|r Map refresh and sound mutes active.")
        end
    else
        -- Clean up when leaving
        for _, id in ipairs(soundIDs) do
            UnmuteSoundFile(id)
        end
        
        if f.ticker then
            f.ticker:Cancel()
            f.ticker = nil
            print("|cffff0000Silvershard Fix:|r Deactivated.")
        end
    end
end

f:SetScript("OnEvent", CheckZone)
