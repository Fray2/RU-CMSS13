/datum/action/xeno_action/activable/pounce/facehugger/post_windup_effects(interrupted)
	..()

	var/mob/living/carbon/xenomorph/facehugger = owner
	if(!istype(facehugger) || interrupted)
		return
	facehugger.update_icons(TRUE)

/datum/action/xeno_action/activable/pounce/facehugger/additional_effects(mob/living/L)
	if(!ishuman(L))
		return

	var/mob/living/carbon/xenomorph/facehugger/facehugger = owner
	if(!istype(facehugger))
		return

	var/key_name = key_name(facehugger)
	var/did_hug = FALSE
//RUCM EDIT START
	var/client/hugging_client = facehugger.client
//RUCM EDIT END
	if(facehugger.pounce_distance <= 1 && can_hug(L, facehugger.hivenumber))
		did_hug = facehugger.handle_hug(L)
	log_attack("[key_name] [did_hug ? "successfully hugged" : "tried to hug"] [key_name(L)] (Pounce Distance: [facehugger.pounce_distance]) at [get_location_in_text(L)]")
//RUCM EDIT START
	if(did_hug && hugging_client)
		SEND_SIGNAL(hugging_client.mob, COMSIG_XENO_FACEHUGGED_HUMAN) //handle_hug deletes the hugger
//RUCM EDIT END

/datum/action/xeno_action/activable/pounce/facehugger/use_ability()
	for(var/obj/structure/machinery/door/airlock/current_airlock in get_turf(owner))
		if(current_airlock.density) //if its CLOSED YOU'RE SCUTTLING AND CANNOT POUNCE!!!
			to_chat(owner, SPAN_WARNING("We cannot do that while squeezing and scuttling!"))
			return FALSE
	return ..()
