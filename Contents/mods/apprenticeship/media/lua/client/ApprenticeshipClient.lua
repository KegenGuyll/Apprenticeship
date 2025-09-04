require "ISPlayerStatsUI.lua"
TextAPI = require "TextAPI"


Events.OnGameStart.Add(function()
  -- Setting default options for TextAPI
  local LimeGreenColor = { 93, 219, 79, 1 }
  TextAPI.SetDefaults({
    color = LimeGreenColor,
    headZ = 0.85,
    behavior = 'stack',
    wrap = true,
    wrapWidthPx = 300
  })
end)

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

local function CalculateMentalBreakthroughXP(baseXp, studentLevel, teacherLevel, constants)
  -- New formula:
  -- (baseXp * baseMult) + ((targetLevel * (MIN(targetLevelStudent, plateauLevel) / 10)) * perLevelBonus)
  -- Where plateauLevel == targetLevel

  local baseMult = (constants and constants.baseMult) or 1.0
  local perLevelBonus = (constants and constants.perLevelBonus) or 1.0

  local targetLevel = teacherLevel
  local plateauLevel = targetLevel -- Same as targetLevel per requirement
  local targetLevelStudent = studentLevel

  -- effectiveLevel will cause the xp to plateau at this level
  local effectiveLevel = math.min(targetLevelStudent, plateauLevel)

  local result = (baseXp * baseMult) + ((targetLevel * (effectiveLevel / 10)) * perLevelBonus)

  return result
end

local function AddXP(character, perk, level)
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
    -- Enforce skill floor: teacher must be at least minTeacherLevel in this perk
    local minLevel = (Apprenticeship.sandboxSettings and Apprenticeship.sandboxSettings.minTeacherLevel) or 0
    if teacher.getPerkLevel and teacher:getPerkLevel(perk) < minLevel then
      print("Skipping " .. perk:getName() .. " because teacher level is below minimum")
      return
    end

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
        -- Correct Euclidean distance (sqrt(dx^2 + dy^2))
        local dx = teacher:getX() - onlinePlayer:getX();
        local dy = teacher:getY() - onlinePlayer:getY();
        local distance = math.sqrt(dx * dx + dy * dy);

        if distance <= Apprenticeship.sandboxSettings.maxDistance then
          local args = {
            target = onlinePlayer:getOnlineID(),
            teacher = teacher:getOnlineID(),
            teacherTrait = "",
            teacherTraitReadable = "",
            perk = perk:getId(),
            -- default amount is 1/5 of the level
            amount = level / Apprenticeship.sandboxSettings.defaultTeachingAmount
          }

          if teacher:HasTrait("savant") then
            print("savant trait found")
            if teacher:getXp():getPerkBoost(perk) ~= 0 then
              print("boosted " .. perk:getName() .. " because of savant");
              args.teacherTrait = "savant";
              args.teacherTraitReadable = "Savant";
              args.amount = level / Apprenticeship.sandboxSettings.savantTraitGain;
            end
          end

          if teacher:HasTrait("professor") then
            print("professor trait found")
            args.teacherTrait = "professor";
            args.teacherTraitReadable = "Professor";
            args.amount = level / Apprenticeship.sandboxSettings.professorTraitGain;
          end

          if teacher:HasTrait("badTeacher") then
            print("badTeacher trait found")
            args.teacherTrait = "badTeacher";
            args.teacherTraitReadable = "Bad Teacher";
            args.amount = level / Apprenticeship.sandboxSettings.badTeacherTraitGain;
          end

          --- send the TeachPerk command to the server
          sendClientCommand("Apprenticeship", "AddXP", args)

          if Apprenticeship.sandboxSettings.hideTeacherHaloText == false then
            local fullText = "Teaching " ..
                onlinePlayer:getDisplayName() ..
                " " .. roundNumber(args.amount) .. " XP " .. "(" .. perk:getName() .. ")";
            TextAPI.ShowOverheadText(teacher, fullText)
          end
        end
      end
    end
  end
end


--- more client stuff!
local function handleServerCommand(module, command, args)
  if module == "Apprenticeship" and command == "AddXP" then
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

    -- Calculate potential "Breakthrough" bonus XP on the student side
    local finalAmount = args.amount
    local haloPrefix = nil

    local sb = Apprenticeship.sandboxSettings or {}
    local breakthroughsEnabled = sb.enableBreakthroughs == true
    local chanceN = sb.breakthroughsChanceN or 1000

    -- Use ZombRand if available for consistency with PZ, fallback to math.random
    local function rollBreakthrough(n)
      if ZombRand ~= nil then
        return ZombRand(n) == 0
      else
        return math.random(0, n - 1) == 0
      end
    end

    if breakthroughsEnabled and chanceN and chanceN > 0 and rollBreakthrough(chanceN) then
      local studentLevel = target:getPerkLevel(perk)
      local teacherLevel = teacher and teacher:getPerkLevel(perk) or 0
      local constants = {
        -- base multiplier applied to the base XP amount
        baseMult = sb.breakthroughsBaseMultiplier or 1.0,
        -- per-level bonus applied to the teacher level scaled by min(student, teacher)
        perLevelBonus = sb.breakthroughsPerLevelBonus or 1.0
      }
      local bonus = CalculateMentalBreakthroughXP(finalAmount, studentLevel, teacherLevel, constants)
      finalAmount = finalAmount + bonus
      haloPrefix = "BREAKTHROUGH! +" .. roundNumber(bonus) .. " XP "
    end

    if Apprenticeship.sandboxSettings.hideStudentHaloText == false then
      local baseText = "Learning from " .. teacher:getDisplayName() .. " " .. roundNumber(finalAmount) .. " XP " ..
          "(" .. perk:getName() .. ")"
      local fullText = (haloPrefix and (haloPrefix .. "— ") or "") .. baseText
      target:setHaloNote(fullText)
    end

    target:getXp():AddXP(perk, finalAmount, false, true, true)
  end
end

--* Events *--
Events.AddXP.Add(AddXP)
-- triggered when the client receives a command from the server
Events.OnServerCommand.Add(handleServerCommand)
