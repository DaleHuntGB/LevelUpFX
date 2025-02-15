local _, namespace = ...

-- Reference to the currently displayed frame
namespace.currentFrame = nil
local isMoving = false;

-- Get Frame Position, Save to Settings
local function GetFramePosition(frame)
	local _, _, _, x, y = frame:GetPoint()
	local anchorX = math.floor(x)
	local anchorY = math.floor(y)
	namespace:SetOption("frameAnchorX", anchorX)
	namespace:SetOption("frameAnchorY", anchorY)
	print("Frame Position Set - xPos: " .. anchorX .. " | yPos: " .. anchorY)
end

-- Function to create and show the level-up message
local function ShowLevelUpMessage(level, statGains, isMoving)
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
	local xPos, yPos = namespace:GetOption("frameAnchorX"), namespace:GetOption("frameAnchorY")
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
	if not isMoving then
		local fadeOutAnimation = frame:CreateAnimationGroup()
		local fadeOut = fadeOutAnimation:CreateAnimation("Alpha")
		fadeOut:SetFromAlpha(1)
		fadeOut:SetToAlpha(0)
		local popupDuration = namespace:GetOption("popupDuration")
		fadeOut:SetDuration(popupDuration)
		fadeOut:SetStartDelay(4) -- Delay before fading
		fadeOut:SetSmoothing("OUT")
		fadeOutAnimation:SetScript("OnFinished", function()
			frame:Hide()
		end)
		frame:Show()
		fadeOutAnimation:Play()
	else
	-- Allow Dragging During `isMoving`
		frame:SetMovable(true)
		frame:EnableMouse(true)
		frame:RegisterForDrag("LeftButton")
		frame:SetScript("OnDragStart", function(self) 
			self:StartMoving()
			self:ClearAllPoints()
			end)
		frame:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
			GetFramePosition(self)
		end)
		frame:Show()
	end

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

-- Slash command for testing
namespace:RegisterSlash("/lu", function(msg)
	if msg == "test" then
		local testLevel = tonumber(msg) or math.random(2, 60)
		local statGains = {
			Strength = math.random(0, 5),
			Agility = math.random(0, 5),
			Stamina = math.random(0, 5),
			Intellect = math.random(0, 5),
			Spirit = math.random(0, 5),
		}
		ShowLevelUpMessage(testLevel, statGains, false)
	elseif msg == "unlock" then
		ShowLevelUpMessage(60, {Strength = 5, Agility = 5, Stamina = 5, Intellect = 5, Spirit = 5}, true)
	elseif msg == "lock" then
		isMoving = false;
		if namespace.currentFrame then
			namespace.currentFrame:StopMovingOrSizing()
			GetFramePosition(namespace.currentFrame)
			namespace.currentFrame:Hide()
		end
	else
		print("Usage: /lu test [level] | /lu unlock | /lu lock")
	end
end)
