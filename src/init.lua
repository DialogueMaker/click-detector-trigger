--!strict
-- Automatically triggers the dialogue server when the player clicks on a floating speech bubble.
--
-- Programmers: Christian Toney (Christian_Toney)
-- © 2023 – 2025 Dialogue Maker Group

local CollectionService = game:GetService("CollectionService");

local packages = script.Parent.roblox_packages;
local IClient = require(packages.client_types);
local IConversation = require(packages.conversation_types);

type Client = IClient.Client;
type Conversation = IConversation.Conversation;

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
        client.ConversationChanged:Connect(function()

          clickDetector.Parent = if client:getConversation() == nil then originalParent else nil;

        end);

        clickDetector.MouseClick:Connect(function()

          if client:getConversation() == nil then

            client:interact(conversation);

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