local _, namespace = ...

-- Reference to the currently displayed frame
namespace.currentFrame = nil

-- Function to create and show the level-up message
local function ShowLevelUpMessage(level, statGains)
	if not namespace:GetOption("enableAddon") then
		return
	end

	-- Hide any existing frame to prevent overlap
	if namespace.currentFrame and namespace.currentFrame:IsShown() then
		namespace.currentFrame:Hide()
	end

	-- Create the main frame for the level-up display
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(600, 150) -- Adjusted width to accommodate horizontal layout
	local xPos = namespace:GetOption("frameAnchorX")
	local yPos = namespace:GetOption("frameAnchorY")
	frame:SetPoint("CENTER", xPos, yPos)
	frame:SetScale(namespace:GetOption("frameScale")) -- Apply scale from settings
	namespace.currentFrame = frame -- Save reference to the current frame

	-- Background texture
	local background = frame:CreateTexture(nil, "BACKGROUND")
	background:SetTexture("Interface/Addons/LevelUpFX/Media/LevelUpTex")
	background:SetPoint("BOTTOM")
	background:SetSize(326, 103)
	background:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	background:SetVertexColor(1, 1, 1, 0.7)

	-- Top gold bar
	local topBar = frame:CreateTexture(nil, "ARTWORK")
	topBar:SetDrawLayer("BACKGROUND", 2)
	topBar:SetTexture("Interface/Addons/LevelUpFX/Media/LevelUpTex")
	topBar:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	topBar:SetSize(430, 12)
	topBar:SetPoint("TOP")

	-- Bottom gold bar
	local bottomBar = frame:CreateTexture(nil, "ARTWORK")
	bottomBar:SetDrawLayer("BACKGROUND", 2)
	bottomBar:SetTexture("Interface/Addons/LevelUpFX/Media/LevelUpTex")
	bottomBar:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	bottomBar:SetSize(430, 12)
	bottomBar:SetPoint("BOTTOM")

	-- "You've Reached" text
	local headerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
	headerText:SetPoint("CENTER", 0, 40)
	headerText:SetFont("Fonts\\FRIZQT__.TTF", 30, "OUTLINE")
	headerText:SetText("|cFFFFFFFF" .. LEVEL_UP_YOU_REACHED .. "|r") -- White text

	-- "Level X" text
	local levelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
	levelText:SetPoint("CENTER", 0, -12)
	levelText:SetFont("Fonts\\FRIZQT__.TTF", 50, "OUTLINE")
	levelText:SetText(string.format("|cFFFFD700" .. LEVEL .. " %d|r", level)) -- Gold text

	-- Display stat increases horizontally
	local statFrame = CreateFrame("Frame", nil, frame)
	statFrame:SetSize(600, 30) -- Container for stat texts
	statFrame:SetPoint("BOTTOM", 0, 5)

	local font = "Fonts\\FRIZQT__.TTF"
	local fontSize = 16
	local statTexts = {}

	for stat, value in pairs(statGains) do
		if value > 0 then
			local statText = string.format("|cFF00FF00+%d %s|r", value, stat)
			table.insert(statTexts, statText)
		end
	end

	if #statTexts > 0 then
		local statString = table.concat(statTexts, ", ")
		local statFontString = statFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		statFontString:SetFont(font, fontSize, "OUTLINE")
		statFontString:SetText(statString)
		statFontString:SetPoint("CENTER", statFrame, "CENTER", 0, 0)
	else
		print("No stats to display. Tell Kkthnx.")
	end

	-- Fade-out animation
	local fadeOutAnimation = frame:CreateAnimationGroup()
	local fadeOut = fadeOutAnimation:CreateAnimation("Alpha")
	fadeOut:SetFromAlpha(1)
	fadeOut:SetToAlpha(0)
	fadeOut:SetDuration(2) -- 2 seconds to fade out
	fadeOut:SetStartDelay(4) -- Delay before fading
	fadeOut:SetSmoothing("OUT")
	fadeOutAnimation:SetScript("OnFinished", function()
		frame:Hide()
	end)

	-- Show the frame and start the animation
	frame:Show()
	fadeOutAnimation:Play()

	-- Perform the "CHEER" emote if enabled
	if namespace:GetOption("cheerOnLevelUp") then
		if math.random() < 0.5 then
			DoEmote("CHEER")
		end
	end

	-- Send chat emote if enabled
	if namespace:GetOption("chatEmoteOnLevelUp") then
		SendChatMessage("has reached level " .. level .. "!", "EMOTE")
	end
end

-- Event handler
namespace:RegisterEvent("PLAYER_LEVEL_UP", function(_, level, _, _, _, strengthDelta, agilityDelta, staminaDelta, intellectDelta, spiritDelta)
	local statGains = {
		Strength = strengthDelta or 0,
		Agility = agilityDelta or 0,
		Stamina = staminaDelta or 0,
		Intellect = intellectDelta or 0,
		Spirit = spiritDelta or 0,
	}
	ShowLevelUpMessage(level, statGains)
end)

function LevelUpTest(msg)
	if msg == "test" then 
		ShowLevelUpMessage(math.random(2, 60), {Strength = math.random(1, 5), Agility = math.random(1, 5), Stamina = math.random(1, 5), Intellect = math.random(1, 5), Spirit = math.random(1, 5)})
	elseif msg == "move" then
		UnlockFrame();
		print("Frame Unlocked. Drag To A Desired Position.")
	else
		print("Usage: /lu test - Display a test level-up message")
		print("Usage: /lu move - Unlock the level-up frame for dragging")
	end
end

-- Slash command for testing
namespace:RegisterSlash("/lu", function(msg) LevelUpTest(msg) end)
