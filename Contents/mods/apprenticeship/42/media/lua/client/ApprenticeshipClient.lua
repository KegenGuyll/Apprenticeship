require "ISPlayerStatsUI.lua"
require('APP_options');

local function  isPerkDisabled(perk)
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
      return math.floor(num * 10) / 10 -- Round down
  else 
      return math.ceil(num * 10) / 10 -- Round up
  end
end

local function AddXP(character, perk, level)
  local players = getOnlinePlayers();
  local array_size 	= players:size();
  local teacher = nil;
  local teacherOnlineId = character:getOnlineID();
  local traitIds = APP_OPTIONS.traitIds;

  local shouldSkip = isPerkDisabled(perk);

  if shouldSkip then
    print("Skipping " .. perk:getName() .. " because it's disabled");
    return;
  end

  for i=0, array_size-1, 1 do
    local onlinePlayer = players:get(i);

    if onlinePlayer:getOnlineID() == teacherOnlineId then
      teacher = onlinePlayer;
      break;
    end
  end

  if teacher ~= nil then


    if teacher:HasTrait(traitIds.classDismissed) then
      print("Skipping " .. perk:getName() .. " because teacher has classDismissed");
      return;
    end

    if teacher:HasTrait(traitIds.dunce) then
      print("Skipping " .. perk:getName() .. " because teacher has dunce");
      return;
    end

    for i=0, array_size-1, 1 do
      local onlinePlayer = players:get(i);

      if onlinePlayer:getOnlineID() ~= teacherOnlineId then
        local distance = math.sqrt((teacher:getX() - onlinePlayer:getX())^2 + (teacher:getY() - onlinePlayer:getY())^2);

        if distance <= Apprenticeship.sandboxSettings.maxDistance then

          local args = {
            target = onlinePlayer:getOnlineID(),
            teacher = teacher:getOnlineID(),
            perk = perk:getId(),
            -- default amount is 1/5 of the level
            amount = level / Apprenticeship.sandboxSettings.defaultTeachingAmount
          }

          if teacher:HasTrait(traitIds.savant) then
            print("savant trait found")
            if teacher:getXp():getPerkBoost(perk) ~= 0 then
              print("boosted " .. perk:getName() .. " because of savant");
              args.amount = level / Apprenticeship.sandboxSettings.savantTraitGain;
            end
          end

          if teacher:HasTrait(traitIds.professor) then
            print("professor trait found")
            args.amount = level / Apprenticeship.sandboxSettings.professorTraitGain;
          end

          if teacher:HasTrait(traitIds.badTeacher) then
            print("badTeacher trait found")
            args.amount = level / Apprenticeship.sandboxSettings.badTeacherTraitGain;
          end

          --- send the TeachPerk command to the server
          sendClientCommand(APP_OPTIONS.moduleName, APP_OPTIONS.commandName, args)
          
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
  if module == APP_OPTIONS.moduleName and command == APP_OPTIONS.commandName then
      local target = getPlayerByOnlineID(args.target)
      local teacher = getPlayerByOnlineID(args.teacher)
      local perk = Perks[args.perk]
      local traitIds = APP_OPTIONS.traitIds;

      if (not target) or (not teacher) or (not perk) then
        return;
      end

      if target:HasTrait(traitIds.dunce) then
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
        target:setHaloNote("Learning from " .. teacher:getDisplayName() .. " " .. roundNumber(args.amount) .. " XP " .. "(" .. perk:getName() .. ")");
      end

      target:getXp():AddXP(perk, args.amount, false, true)
  end
end

--* Events *--
Events.AddXP.Add(AddXP)
-- triggered when the client receives a command from the server
Events.OnServerCommand.Add(handleServerCommand)