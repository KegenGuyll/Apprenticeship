require('NPCs/MainCreationMethods');

local function  initTraits()
  local savant = TraitFactory.addTrait("savant", getText("UI_trait_savant"), 1, getText("UI_trait_savantdesc"), false, false);
  local professor = TraitFactory.addTrait("professor", getText("UI_trait_professor"), 3, getText("UI_trait_professordesc"), false, false);

  local badTeacher = TraitFactory.addTrait("badTeacher", getText("UI_trait_badTeacher"), -1, getText("UI_trait_badTeacherdesc"), false, false);
  local classDismissed = TraitFactory.addTrait("classDismissed", getText("UI_trait_classDismissed"), -3, getText("UI_trait_classDismisseddesc"), false, false);

  TraitFactory.setMutualExclusive('savant', 'badTeacher')
  TraitFactory.setMutualExclusive('savant', 'classDismissed')

  TraitFactory.setMutualExclusive('professor', 'badTeacher')
  TraitFactory.setMutualExclusive('professor', 'classDismissed')
end


Events.OnGameBoot.Add(initTraits);