
/mob/living/carbon/xenomorph/proc/crusher_rage_bonus()
	var/duration = 4 SECONDS
	var/speed_bonus = 0.4
	var/atack_rate_enchant = -4
	if(!(LAZYISIN(modifier_sources, XENO_FRUIT_SPEED))) //Дабы не стакалось с цветком, иначе это выйдет просто фура
		new /datum/effects/xeno_speed(src,  ttl = duration, set_speed_modifier = speed_bonus, set_modifier_source = XENO_FRUIT_SPEED, set_end_message = SPAN_XENONOTICE("We feel ourselves exhausted..."))
	attack_speed_modifier = (initial(attack_speed_modifier) + atack_rate_enchant)
	addtimer(CALLBACK(src, PROC_REF(remove_crusher_rage_bonus)), duration)

/mob/living/carbon/xenomorph/proc/remove_crusher_rage_bonus()
	attack_speed_modifier = initial(attack_speed_modifier)
	return
