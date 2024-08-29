//Additional requirements for main task, that will make it harder to complete
/datum/battlepass_challenge_module/requirement

//Additional
/datum/battlepass_challenge_module/requirement/additional


/datum/battlepass_challenge_module/requirement/additional/damage
	name = "Damage"
	desc = " survive minimum ###damage### damage"
	code_name = "additional_survive_damage"

	module_exp = list(4, 10)

	req_gen = list("damage" = list(1000, 6000))

/datum/battlepass_challenge_module/requirement/additional/damage/hook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	var/req_name = req[1]
	if(req[req_name][1] == req[req_name][2])
		return
	RegisterSignal(SSdcs, COMSIG_GLOB_CONFIG_LOADED, PROC_REF(on_game_end), logged_mob)

/datum/battlepass_challenge_module/requirement/additional/damage/unhook_signals(mob/logged_mob)
	. = ..()
	if(!.)
		return
	UnregisterSignal(SSdcs, COMSIG_GLOB_CONFIG_LOADED)

/datum/battlepass_challenge_module/requirement/additional/damage/proc/on_game_end(mob/logged_mob)
	var/req_name = req[1]
	if(req[req_name][1] == req[req_name][2])
		return
	req[req_name][1] = min(logged_mob.life_damage_taken_total, req[req_name][2])
	on_possible_challenge_completed()


/datum/battlepass_challenge_module/requirement/additional/weapon
	name = "Weapon"
	desc = "using a ###weapon###"
	code_name = "weapon"

	module_exp_modificator = 1.25

	var/list/possible_weapons = list()
	var/obj/weapon_to_use

/datum/battlepass_challenge_module/requirement/additional/weapon/get_description()
	. = ..()
	. = replacetext_char(., "###weapon###", initial(weapon_to_use.name))

/datum/battlepass_challenge_module/requirement/additional/weapon/allow_completion(mob/source, mob/killed_mob, datum/cause_data/cause_data)
	if(!findtext(cause_data.cause_name, weapon_to_use))
		return FALSE
	return TRUE

/datum/battlepass_challenge_module/requirement/additional/weapon/serialize(list/options)
	. = ..()
	options["weapon_to_use"] = weapon_to_use

/datum/battlepass_challenge_module/requirement/additional/weapon/common
	code_name = "weapon_common"

	module_exp_modificator = 1.2

	possible_weapons = list(
		/obj/item/weapon/gun/smg/m39,
		/obj/item/weapon/gun/rifle/m4ra,
		/obj/item/weapon/gun/rifle/m41a,
		/obj/item/weapon/gun/shotgun/pump,
	)

/datum/battlepass_challenge_module/requirement/additional/weapon/pistol
	code_name = "weapon_pistol"

	module_exp_modificator = 1.5

	possible_weapons = list(
		/obj/item/storage/box/guncase/vp78,
		/obj/item/storage/box/guncase/smartpistol,
		/obj/item/weapon/gun/pistol/mod88,
		/obj/item/weapon/gun/revolver/m44,
		/obj/item/weapon/gun/pistol/m4a3,
	)

/datum/battlepass_challenge_module/requirement/additional/weapon/req
	code_name = "weapon_req"

	module_exp_modificator = 1.1

	possible_weapons = list(
		/obj/item/weapon/gun/flamer,
		/obj/item/weapon/gun/shotgun/double/mou53,
		/obj/item/storage/box/guncase/xm88,
		/obj/item/weapon/gun/rifle/m41a,
		/obj/item/storage/box/guncase/m41aMK1,
		/obj/item/storage/box/guncase/lmg,
	)
//


//Buffs
/datum/battlepass_challenge_module/requirement/good_buffs // Хороший, баф который должен быть исключен для выполенния задания (саб задание)

/datum/battlepass_challenge_module/requirement/good_buffs/ammunition
	name = "Ammunition"
	desc = " ammunition ###type###"
	code_name = "overdose"

	module_exp = list(2, 4)

	var/list/ammo_types = list()

/datum/battlepass_challenge_module/requirement/good_buffs/reagents
	name = "Reagents"
	desc = " any reagents in blood"
	code_name = "reagents"

	module_exp = list(2, 4)

/datum/battlepass_challenge_module/requirement/good_buffs/reagents/allow_completion()
	if(!challenge_ref.client_reference?.mob)
		return FALSE
	if(length(challenge_ref.client_reference.mob.reagents.reagent_list))
		return FALSE
	return TRUE
//


//Debuffs
/datum/battlepass_challenge_module/requirement/bad_buffs // Плохой баф, который должен быть для выполнения задания (саб задание)

/datum/battlepass_challenge_module/requirement/bad_buffs/overdose
	name = "OD"
	desc = " OD ###type###"
	code_name = "overdose"

	module_exp = list(2, 4)

	var/critical = FALSE
	var/datum/reagent/chem_overdose

/datum/battlepass_challenge_module/requirement/bad_buffs/overdose/generate_module()
	critical = prob(25)
	if(critical)
		module_exp_modificator = 1.5
	var/selected_class = pick(list(CHEM_CLASS_BASIC, CHEM_CLASS_COMMON, CHEM_CLASS_UNCOMMON, CHEM_CLASS_RARE))
	switch(selected_class)
		if(CHEM_CLASS_BASIC)
			module_exp_modificator -= 0.25
		if(CHEM_CLASS_COMMON)
			module_exp_modificator += 0.25
		if(CHEM_CLASS_UNCOMMON)
			module_exp_modificator += 0.5
		if(CHEM_CLASS_RARE)
			module_exp_modificator += 1
	var/list/pick_ragetns = list()
	for(var/datum/reagent/reagent in subtypesof(/datum/reagent/medical))
		if(selected_class != initial(reagent.chemclass))
			continue
		pick_ragetns += reagent
	if(!length(pick_ragetns))
		return FALSE
	chem_overdose = pick(pick_ragetns)
	return TRUE

/datum/battlepass_challenge_module/requirement/bad_buffs/overdose/get_description()
	. = ..()
	. = replacetext_char(., "###type###", initial(chem_overdose.name))

/datum/battlepass_challenge_module/requirement/bad_buffs/overdose/serialize(list/options)
	. = ..()
	options["critical"] = critical
	options["chem_overdose"] = chem_overdose

/datum/battlepass_challenge_module/requirement/bad_buffs/overdose/allow_completion()
	if(!challenge_ref.client_reference?.mob)
		return FALSE
	for(var/datum/reagent/reagent in challenge_ref.client_reference.mob.reagents.reagent_list)
		if(reagent.flags & REAGENT_CANNOT_OVERDOSE)
			continue

		if(!istype(reagent, chem_overdose))
			continue

		if(!critical)
			if(reagent.overdose && reagent.volume > reagent.overdose)
				return TRUE
		else
			if(reagent.overdose_critical && reagent.volume > reagent.overdose_critical)
				return TRUE
	return FALSE
//
