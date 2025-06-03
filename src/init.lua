--!strict
-- Automatically triggers the dialogue server when the player clicks on a floating speech bubble.
--
-- Programmers: Christian Toney (Christian_Toney)
-- © 2023 – 2025 Dialogue Maker Group

local CollectionService = game:GetService("CollectionService");

local packages = script.Parent.roblox_packages;
local DialogueMakerTypes = require(packages.dialogue_maker_types);

type Client = DialogueMakerTypes.Client;
type Conversation = DialogueMakerTypes.Conversation;

return function(client: Client)

  for _, conversationModuleScript in CollectionService:GetTagged("DialogueMaker_Conversation") do

    local didInitialize, errorMessage = pcall(function()

      -- We're using pcall because require can throw an error if the module is invalid.
      local conversation = require(conversationModuleScript) :: Conversation;
      local conversationSettings = conversation:getSettings();
      local clickDetector = conversationSettings.clickDetector.instance;
      if conversationSettings.clickDetector.shouldAutoCreate then

        assert(conversationSettings.clickDetector.adornee, "ClickDetector adornee must be set if shouldAutoCreate is enabled.");

        local autoCreatedClickDetector = Instance.new("ClickDetector");
        autoCreatedClickDetector.Parent = conversationSettings.clickDetector.adornee;
        clickDetector = autoCreatedClickDetector;

      end;

      if clickDetector then

        local originalParent = clickDetector.Parent;
        client.DialogueChanged:Connect(function()

          clickDetector.Parent = if client:getDialogue() == nil then originalParent else nil;

        end);

        clickDetector.MouseClick:Connect(function()

          if client:getDialogue() == nil then

            local dialogue = conversation:findNextVerifiedDialogue();
            client:setDialogue(dialogue);

          end;

        end);

      end;

    end);

    if not didInitialize then

      local fullName = conversationModuleScript:GetFullName();
      warn(`[Dialogue Maker] Failed to initialize proximity prompt for {fullName}: {errorMessage}`);

    end;

  end;

end;