require "ISPlayerStatsUI.lua"

local function  isPerkDisabled(perk)
  local searchString = "disableTeaching" .. perk:getId();

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
    for i=0, array_size-1, 1 do
      local onlinePlayer = players:get(i);

      if onlinePlayer:getDisplayName() ~= teacher:getDisplayName() then
        local distance = math.sqrt((teacher:getX() - onlinePlayer:getX())^2) + ((teacher:getY() - onlinePlayer:getY())^2);

        if distance <= Apprenticeship.sandboxSettings.maxDistance then

          local args = {
            target = onlinePlayer:getOnlineID(),
            teacher = teacher:getOnlineID(),
            perk = perk:getId(),
            amount = level / 5
          }

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