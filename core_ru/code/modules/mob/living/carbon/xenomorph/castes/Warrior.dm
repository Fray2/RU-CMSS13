/datum/caste_datum/warrior
	available_strains = list(/datum/xeno_strain/boxer)

/mob/living/carbon/xenomorph/Warrior/proc/handle_warrior_effects()
	var/datum/behavior_delegate/boxer/behavior_boxer = behavior_delegate
	if(!istype(behavior_boxer) || behavior_boxer.clear_head <= 0)
		return TRUE

	if(behavior_boxer.clear_head_tickcancel == world.time)
		return

	behavior_boxer.clear_head_tickcancel = world.time
	behavior_boxer.clear_head--
	if(behavior_boxer.clear_head <= 0)
		behavior_boxer.clear_head = 0

// a lot of repeats but it's because we are calling different parent procs
/mob/living/carbon/xenomorph/Warrior/Daze(amount)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/SetDaze(amount)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/AdjustDaze(amount)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/KnockDown(amount, forced)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/SetKnockDown(amount)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/AdjustKnockDown(amount)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/Stun(amount)
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/SetStun(amount) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(handle_warrior_effects())
		return ..(amount)

/mob/living/carbon/xenomorph/Warrior/AdjustStun(amount)
	if(handle_warrior_effects())
		return ..(amount)
