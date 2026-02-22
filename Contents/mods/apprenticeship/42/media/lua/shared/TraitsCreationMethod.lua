require('NPCs/MainCreationMethods');
require('APP_options');

local function  initTraits()
  local traitIds = APP_OPTIONS.traitIds;
  local savant = TraitFactory.addTrait(traitIds.savant, getText("UI_trait_savant"), 1, getText("UI_trait_savantdesc"), false, false);
  local professor = TraitFactory.addTrait(traitIds.professor, getText("UI_trait_professor"), 3, getText("UI_trait_professordesc"), false, false);

  local badTeacher = TraitFactory.addTrait(traitIds.badTeacher, getText("UI_trait_badTeacher"), -1, getText("UI_trait_badTeacherdesc"), false, false);
  local classDismissed = TraitFactory.addTrait(traitIds.classDismissed, getText("UI_trait_classDismissed"), -3, getText("UI_trait_classDismisseddesc"), false, false);

  local dunce = TraitFactory.addTrait(traitIds.dunce, getText("UI_trait_dunce"), -4, getText("UI_trait_duncedesc"), false, false);

  TraitFactory.setMutualExclusive(traitIds.savant, traitIds.badTeacher)
  TraitFactory.setMutualExclusive(traitIds.savant, traitIds.classDismissed)
  TraitFactory.setMutualExclusive(traitIds.savant, traitIds.professor)
  TraitFactory.setMutualExclusive(traitIds.savant, traitIds.dunce)

  TraitFactory.setMutualExclusive(traitIds.professor, traitIds.badTeacher)
  TraitFactory.setMutualExclusive(traitIds.professor, traitIds.classDismissed)
  TraitFactory.setMutualExclusive(traitIds.professor, traitIds.dunce)

  TraitFactory.setMutualExclusive(traitIds.badTeacher, traitIds.classDismissed)
  TraitFactory.setMutualExclusive(traitIds.badTeacher, traitIds.dunce)


  TraitFactory.setMutualExclusive(traitIds.classDismissed, traitIds.dunce)
end


Events.OnGameBoot.Add(initTraits);