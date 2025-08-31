Apprenticeship = Apprenticeship or {};
Apprenticeship.server = {};
Apprenticeship.constants = {};
Apprenticeship.sandboxSettings = {};

Apprenticeship.server.fetchSandboxVars = function()
  Apprenticeship.sandboxSettings.maxDistance = SandboxVars.Apprenticeship.maxDistance;
  Apprenticeship.sandboxSettings.disableTeachingAgility = SandboxVars.Apprenticeship.disableTeachingAgility;
  Apprenticeship.sandboxSettings.disableTeachingAiming = SandboxVars.Apprenticeship.disableTeachingAiming;
  Apprenticeship.sandboxSettings.disableTeachingAxe = SandboxVars.Apprenticeship.disableTeachingAxe;
  Apprenticeship.sandboxSettings.disableTeachingCooking = SandboxVars.Apprenticeship.disableTeachingCooking;
  Apprenticeship.sandboxSettings.disableTeachingDoctor = SandboxVars.Apprenticeship.disableTeachingDoctor;
  Apprenticeship.sandboxSettings.disableTeachingElectricity = SandboxVars.Apprenticeship.disableTeachingElectricity;
  Apprenticeship.sandboxSettings.disableTeachingFarming = SandboxVars.Apprenticeship.disableTeachingFarming;
  Apprenticeship.sandboxSettings.disableTeachingFishing = SandboxVars.Apprenticeship.disableTeachingFishing;
  Apprenticeship.sandboxSettings.disableTeachingFitness = SandboxVars.Apprenticeship.disableTeachingFitness;
  Apprenticeship.sandboxSettings.disableTeachingLightfoot = SandboxVars.Apprenticeship.disableTeachingLightfoot;
  Apprenticeship.sandboxSettings.disableTeachingLongBlade = SandboxVars.Apprenticeship.disableTeachingLongBlade;
  Apprenticeship.sandboxSettings.disableTeachingMaintenance = SandboxVars.Apprenticeship.disableTeachingMaintenance;
  Apprenticeship.sandboxSettings.disableTeachingMechanics = SandboxVars.Apprenticeship.disableTeachingMechanics;
  Apprenticeship.sandboxSettings.disableTeachingMetalWelding = SandboxVars.Apprenticeship.disableTeachingMetalWelding;
  Apprenticeship.sandboxSettings.disableTeachingNimble = SandboxVars.Apprenticeship.disableTeachingNimble;
  Apprenticeship.sandboxSettings.disableTeachingPlantScavenging = SandboxVars.Apprenticeship
      .disableTeachingPlantScavenging;
  Apprenticeship.sandboxSettings.disableTeachingReloading = SandboxVars.Apprenticeship.disableTeachingReloading;
  Apprenticeship.sandboxSettings.disableTeachingSmallBlade = SandboxVars.Apprenticeship.disableTeachingSmallBlade;
  Apprenticeship.sandboxSettings.disableTeachingSmallBlunt = SandboxVars.Apprenticeship.disableTeachingSmallBlunt;
  Apprenticeship.sandboxSettings.disableTeachingSneak = SandboxVars.Apprenticeship.disableTeachingSneak;
  Apprenticeship.sandboxSettings.disableTeachingSpear = SandboxVars.Apprenticeship.disableTeachingSpear;
  Apprenticeship.sandboxSettings.disableTeachingSprinting = SandboxVars.Apprenticeship.disableTeachingSprinting;
  Apprenticeship.sandboxSettings.disableTeachingStrength = SandboxVars.Apprenticeship.disableTeachingStrength;
  Apprenticeship.sandboxSettings.disableTeachingSurvivalist = SandboxVars.Apprenticeship.disableTeachingSurvivalist;
  Apprenticeship.sandboxSettings.disableTeachingTailoring = SandboxVars.Apprenticeship.disableTeachingTailoring;
  Apprenticeship.sandboxSettings.disableTeachingTrapping = SandboxVars.Apprenticeship.disableTeachingTrapping;
  Apprenticeship.sandboxSettings.disableTeachingWoodwork = SandboxVars.Apprenticeship.disableTeachingWoodwork;
  Apprenticeship.sandboxSettings.hideTeacherHaloText = SandboxVars.Apprenticeship.hideTeacherHaloText;
  Apprenticeship.sandboxSettings.hideStudentHaloText = SandboxVars.Apprenticeship.hideStudentHaloText;
  Apprenticeship.sandboxSettings.disableAllPassiveTeaching = SandboxVars.Apprenticeship.disableAllPassiveTeaching;
  Apprenticeship.sandboxSettings.disableAllAgilityTeaching = SandboxVars.Apprenticeship.disableAllAgilityTeaching;
  Apprenticeship.sandboxSettings.disableAllCombatTeaching = SandboxVars.Apprenticeship.disableAllCombatTeaching;
  Apprenticeship.sandboxSettings.disableAllCraftingTeaching = SandboxVars.Apprenticeship.disableAllCraftingTeaching;
  Apprenticeship.sandboxSettings.disableAllFirearmTeaching = SandboxVars.Apprenticeship.disableAllFirearmTeaching;
  Apprenticeship.sandboxSettings.disableAllSurvivalistTeaching = SandboxVars.Apprenticeship
      .disableAllSurvivalistTeaching;
  Apprenticeship.sandboxSettings.savantTraitGain = SandboxVars.Apprenticeship.savantTraitGain;
  Apprenticeship.sandboxSettings.professorTraitGain = SandboxVars.Apprenticeship.professorTraitGain;
  Apprenticeship.sandboxSettings.badTeacherTraitGain = SandboxVars.Apprenticeship.badTeacherTraitGain;
  Apprenticeship.sandboxSettings.defaultTeachingAmount = SandboxVars.Apprenticeship.defaultTeachingAmount;
  Apprenticeship.sandboxSettings.studentBoredomReduction = SandboxVars.Apprenticeship.studentBoredomReduction;
  Apprenticeship.sandboxSettings.requireSameFaction = SandboxVars.Apprenticeship.requireSameFaction;
end

Apprenticeship.server.setup = function()
  Apprenticeship.server.fetchSandboxVars();
end


--- server file
local function getFactionNameFor(player)
  if not player then return nil end
  local name = nil
  if player.getUsername then
    name = player:getUsername()
  end
  if not name or name == "" then
    name = player:getDisplayName()
  end
  return name
end

local function isSameFaction(p1, p2)
  if p1 == nil or p2 == nil then return false end
  if not Faction or not Faction.getPlayerFaction then return true end
  local n1 = getFactionNameFor(p1)
  local n2 = getFactionNameFor(p2)
  if not n1 or not n2 then return false end
  local f1 = Faction.getPlayerFaction(n1)
  local f2 = Faction.getPlayerFaction(n2)
  if f1 == nil and f2 == nil then return true end
  if f1 ~= nil and f2 ~= nil then
    return f1:getName() == f2:getName()
  end
  return false
end

local function handleClientCommand(module, command, player, args)
  -- make sure we only do stuff if it's actually our command
  if module == "MyMod" and command == "AddXP" then
    local target = getPlayerByOnlineID(args.target)
    local teacher = getPlayerByOnlineID(args.teacher)
    local enforceFaction = true
    if Apprenticeship and Apprenticeship.sandboxSettings and Apprenticeship.sandboxSettings.requireSameFaction ~= nil then
      enforceFaction = Apprenticeship.sandboxSettings.requireSameFaction
    end

    if target and teacher and ((not enforceFaction) or isSameFaction(teacher, target)) then
      -- the target argument sends the command to only that client
      sendServerCommand(target, "MyMod", "AddXP", args)
    else
      -- silently drop if cross-faction to avoid info leak
    end
  end
end
-- triggered when the server receives a command from a client
Events.OnClientCommand.Add(handleClientCommand)

Events.OnGameStart.Add(Apprenticeship.server.setup);
Events.OnGameTimeLoaded.Add(Apprenticeship.server.setup);
