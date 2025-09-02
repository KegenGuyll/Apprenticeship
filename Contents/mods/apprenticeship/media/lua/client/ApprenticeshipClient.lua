require "ISPlayerStatsUI.lua"

-- Returns a username-like identifier for faction lookups
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

-- Check if two players are in the same faction or both factionless
local function isSameFaction(p1, p2)
  if p1 == nil or p2 == nil then return false end
  -- If faction API isn't available (SP/offline), allow by default
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

local function isPerkDisabled(perk)
  local searchString = "disableTeaching" .. perk:getId();
  local perkParent = perk:getParent():getName();

  if Apprenticeship.sandboxSettings.disableAllAgilityTeaching then
    if perkParent == "Agility" then
      return true;
    end
  end

  if Apprenticeship.sandboxSettings.disableAllCombatTeaching then
    if perkParent == "Combat" then
      return true;
    end
  end

  if Apprenticeship.sandboxSettings.disableAllCraftingTeaching then
    if perkParent == "Crafting" then
      return true;
    end
  end

  if Apprenticeship.sandboxSettings.disableAllFirearmTeaching then
    if perkParent == "Firearm" then
      return true;
    end
  end

  if Apprenticeship.sandboxSettings.disableAllSurvivalistTeaching then
    if perkParent == "Survivalist" then
      return true;
    end
  end

  if Apprenticeship.sandboxSettings.disableAllPassiveTeaching then
    if perkParent == "Passive" then
      return true;
    end
  end


  return Apprenticeship.sandboxSettings[searchString];
end

local function roundNumber(num)
  local decimalPart = num - math.floor(num) -- Get decimal part
  if decimalPart < 0.5 then
    return math.floor(num * 10) / 10        -- Round down
  else
    return math.ceil(num * 10) / 10         -- Round up
  end
end

local function OnAddXPEvent(character, perk, level)
  local players    = getOnlinePlayers();
  local array_size = players:size();
  local teacher    = nil;

  local shouldSkip = isPerkDisabled(perk);

  if shouldSkip then
    print("Skipping " .. perk:getName() .. " because it's disabled");
    return;
  end

  for i = 0, array_size - 1, 1 do
    local onlinePlayer = players:get(i);

    if onlinePlayer:getDisplayName() == character:getDisplayName() then
      teacher = onlinePlayer;
      break;
    end
  end

  if teacher ~= nil then
    -- Only teach within the same faction (or both factionless)
    -- Prevents halo text or XP reveals across rival factions


    if teacher:HasTrait("classDismissed") then
      print("Skipping " .. perk:getName() .. " because teacher has classDismissed");
      return;
    end

    if teacher:HasTrait("dunce") then
      print("Skipping " .. perk:getName() .. " because teacher has dunce");
      return;
    end

    for i = 0, array_size - 1, 1 do
      local onlinePlayer = players:get(i);

      if onlinePlayer:getDisplayName() ~= teacher:getDisplayName() then
        local dx = (teacher:getX() - onlinePlayer:getX())
        local dy = (teacher:getY() - onlinePlayer:getY())
        local distance = math.sqrt(dx * dx + dy * dy)

        local enforceFaction = true
        if Apprenticeship and Apprenticeship.sandboxSettings and Apprenticeship.sandboxSettings.requireSameFaction ~= nil then
          enforceFaction = Apprenticeship.sandboxSettings.requireSameFaction
        elseif SandboxVars and SandboxVars.Apprenticeship and SandboxVars.Apprenticeship.requireSameFaction ~= nil then
          -- fallback: read directly if settings table isn't populated on client
          enforceFaction = SandboxVars.Apprenticeship.requireSameFaction
        end

        local factionOk = (not enforceFaction) or isSameFaction(teacher, onlinePlayer)

        if distance <= Apprenticeship.sandboxSettings.maxDistance and factionOk then
          local args = {
            target = onlinePlayer:getOnlineID(),
            teacher = teacher:getOnlineID(),
            perk = perk:getId(),
            -- default amount is 1/5 of the level
            amount = level / Apprenticeship.sandboxSettings.defaultTeachingAmount
          }

          if teacher:HasTrait("savant") then
            print("savant trait found")
            if teacher:getXp():getPerkBoost(perk) ~= 0 then
              print("boosted " .. perk:getName() .. " because of savant");
              args.amount = level / Apprenticeship.sandboxSettings.savantTraitGain;
            end
          end

          if teacher:HasTrait("professor") then
            print("professor trait found")
            args.amount = level / Apprenticeship.sandboxSettings.professorTraitGain;
          end

          if teacher:HasTrait("badTeacher") then
            print("badTeacher trait found")
            args.amount = level / Apprenticeship.sandboxSettings.badTeacherTraitGain;
          end

          --- send the TeachPerk command to the server
          sendClientCommand("MyMod", "AddXP", args)

          if Apprenticeship.sandboxSettings.hideTeacherHaloText == false then
            teacher:setHaloNote("Teaching " .. onlinePlayer:getDisplayName() .. " " .. "(" .. perk:getName() .. ")");
          end
        end
      end
    end
  end
end


--- more client stuff!
local function handleServerCommand(module, command, args)
  if module == "MyMod" and command == "AddXP" then
    local target = getPlayerByOnlineID(args.target)
    local teacher = getPlayerByOnlineID(args.teacher)
    local perk = Perks[args.perk]

    if target:HasTrait("dunce") then
      print("Skipping " .. perk:getName() .. " because target has dunce");
      return;
    end

    if target:getXp():getPerkBoost(perk) ~= 0 then
      local bodydamage = target:getBodyDamage();
      local boredom = bodydamage:getBoredomLevel();

      bodydamage:setBoredomLevel(boredom - Apprenticeship.sandboxSettings.studentBoredomReduction);

      print(target:getDisplayName() .. " is less bored because they have a passion for " .. perk:getName());
    end

    if Apprenticeship.sandboxSettings.hideStudentHaloText == false then
      target:setHaloNote("Learning from " ..
        teacher:getDisplayName() .. " " .. roundNumber(args.amount) .. " XP " .. "(" .. perk:getName() .. ")");
    end

    target:getXp():AddXP(perk, args.amount)
  end
end

--* Events *--
Events.AddXP.Add(OnAddXPEvent)
-- triggered when the client receives a command from the server
Events.OnServerCommand.Add(handleServerCommand)
