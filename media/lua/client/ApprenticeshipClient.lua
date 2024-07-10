require "ISPlayerStatsUI.lua"

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

local function AddXP(character, perk, level)
  local players = getOnlinePlayers();
  local array_size 	= players:size();
  local teacher = nil;

  local shouldSkip = isPerkDisabled(perk);

  if shouldSkip then
    print("Skipping " .. perk:getName() .. " because it's disabled");
    return;
  end

  for i=0, array_size-1, 1 do
    local onlinePlayer = players:get(i);

    if onlinePlayer:getDisplayName() == character:getDisplayName() then
      teacher = onlinePlayer;
      break;
    end
  end

  if teacher ~= nil then

    if teacher:HasTrait("savant") then
      print("savant trait found")

      print("perk boost: " .. teacher:getXp():getPerkBoost(perk));
    end

    if teacher:HasTrait("classDismissed") then
      print("Skipping " .. perk:getName() .. " because teacher has classDismissed");
      return;
    end

    for i=0, array_size-1, 1 do
      local onlinePlayer = players:get(i);

      if onlinePlayer:getDisplayName() ~= teacher:getDisplayName() then
        local distance = math.sqrt((teacher:getX() - onlinePlayer:getX())^2) + ((teacher:getY() - onlinePlayer:getY())^2);

        if distance <= Apprenticeship.sandboxSettings.maxDistance then

          local args = {
            target = onlinePlayer:getOnlineID(),
            teacher = teacher:getOnlineID(),
            perk = perk:getId(),
            -- default amount is 1/5 of the level
            amount = level / 5
          }

          if teacher:HasTrait("savant") then
            print("savant trait found")

            print("perk boost: " .. teacher:getXp():getPerkBoost(perk));

            args.amount = level / 3;
          end

          if teacher:HasTrait("professor") then
            print("professor trait found")
            args.amount = level / 3;
          end

          if teacher:HasTrait("badTeacher") then
            print("badTeacher trait found")
            args.amount = level / 8;
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

      if Apprenticeship.sandboxSettings.hideStudentHaloText == false then
        target:setHaloNote("Learning from " .. teacher:getDisplayName() .. " " .. args.amount .. " XP " .. "(" .. perk:getName() .. ")");
      end

      target:getXp():AddXP(perk, args.amount, false, true, true)
  end
end

--* Events *--
Events.AddXP.Add(AddXP)
-- triggered when the client receives a command from the server
Events.OnServerCommand.Add(handleServerCommand)