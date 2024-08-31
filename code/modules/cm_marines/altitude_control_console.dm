//Handles whether or not hijack has disabled the system
GLOBAL_VAR_INIT(alt_ctrl_disabled, FALSE)

//Defines how much to heat the engines or cool them by, and when to overheat
#define COOLING -10
#define OVERHEAT_COOLING -5
#define HEATING 10
#define B_HEATING 20
#define OVERHEAT 100

/obj/structure/machinery/computer/altitude_control_console
	icon_state = "overwatch"
	name = "\improper Altitude Control Console"
	desc = "The A.C.C console monitors, regulates, and updates the ships attitude and altitude in relation to the AO. It's not rocket science... or maybe it is."
	density = TRUE
	unslashable = TRUE
	unacidable = TRUE
	breakable = FALSE

/obj/structure/machinery/computer/altitude_control_console/ex_act()
	return

/obj/structure/machinery/computer/altitude_control_console/bullet_act()
	return

/obj/structure/machinery/computer/altitude_control_console/attack_hand()
	. = ..()
	if(!skillcheck(usr, SKILL_NAVIGATIONS, SKILL_NAVIGATIONS_TRAINED))
		to_chat(usr, SPAN_WARNING("A window of complex orbital math opens up. You have no idea what you are doing and quickly close it."))
		return
	if(GLOB.alt_ctrl_disabled)
		to_chat(usr, SPAN_WARNING("The Altitude Control Console has been locked by ARES due to Delta Alert."))
		return
	tgui_interact(usr)

/obj/structure/machinery/computer/altitude_control_console/Initialize()
	. = ..()
	START_PROCESSING(SSslowobj, src)

/obj/structure/machinery/computer/altitude_control_console/Destroy()
	STOP_PROCESSING(SSslowobj, src)
	return ..()

/obj/structure/machinery/computer/altitude_control_console/process()
	. = ..()
	//Updating temperature
	var/temperature_change
	switch(GLOB.ship_alt)
		if(SHIP_ALT_LOW)
			if(prob(50))
				temperature_change = HEATING
			else
				temperature_change = B_HEATING
		if(SHIP_ALT_MED)
			temperature_change = COOLING
		if(SHIP_ALT_HIGH)
			if(prob(75))
				temperature_change = OVERHEAT_COOLING
			else
				temperature_change = COOLING
	GLOB.ship_temp = clamp(GLOB.ship_temp += temperature_change, 0, OVERHEAT)

	//Override orbit, announce low orbit
	if(GLOB.ship_alt == SHIP_ALT_HIGH && GLOB.ship_temp == 0)
		ai_silent_announcement("Attention: Engine cooloff completed, automatic stabilization to most optimal geo-synchronous orbit undergoing.", ";", TRUE)
		GLOB.ship_alt = SHIP_ALT_MED
		TIMER_COOLDOWN_START(src, COOLDOWN_ALTITUDE_CHANGE, 20 SECONDS)
		for(var/mob/living/carbon/current_mob in GLOB.living_mob_list)
			if(!is_mainship_level(current_mob.z))
				continue
			shake_camera(current_mob, 4, 2)
			current_mob.apply_effect(3, SLOW)
		return
	if(GLOB.ship_alt == SHIP_ALT_LOW && GLOB.ship_temp >= OVERHEAT)
		ai_silent_announcement("Attention: Low altitude orbital maneuver no longer sustainable, moving to furthest geo-synchronous orbit until engine cooloff.", ";", TRUE)
		GLOB.ship_alt = SHIP_ALT_HIGH
		TIMER_COOLDOWN_START(src, COOLDOWN_ALTITUDE_CHANGE, 20 SECONDS)
		for(var/mob/living/carbon/current_mob in GLOB.living_mob_list)
			if(!is_mainship_level(current_mob.z))
				continue
			current_mob.apply_effect(3, SLOW)
			shake_camera(current_mob, 4, 2)
		return
	if(prob(50))
		return
	else if(GLOB.ship_alt == SHIP_ALT_LOW)
		ai_silent_announcement("Low altitude maneuver currently under performance, full stabilization of the altitude unable to be achieved, maintaining procedures until overheat.", ";", TRUE)
		for(var/mob/living/carbon/current_mob in GLOB.living_mob_list)
			if(!is_mainship_level(current_mob.z))
				continue
			current_mob.apply_effect(3, SLOW)
			shake_camera(current_mob, 4, 2)

//TGUI.... fun... years have gone by, I am dying of old age
/obj/structure/machinery/computer/altitude_control_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AltitudeControlConsole", "[src.name]")
		ui.open()

/obj/structure/machinery/computer/altitude_control_console/ui_state(mob/user)
	return GLOB.not_incapacitated_and_adjacent_state

/obj/structure/machinery/computer/altitude_control_console/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(inoperable())
		return UI_CLOSE

/obj/structure/machinery/computer/altitude_control_console/ui_data(mob/user)
	var/list/data = list()
	data["alt"] = GLOB.ship_alt
	data["temp"] = GLOB.ship_temp

	return data

/obj/structure/machinery/computer/altitude_control_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return
	var/mob/user = ui.user
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_ALTITUDE_CHANGE))
		message_admins("[key_name(user)] tried to change the ship's altitude, but it is still on cooldown.")
		to_chat(user, SPAN_WARNING("Engines pending recalibration to burn again, stand by."))
	else
		switch(action)
			if("low_alt")
				change_altitude(user, SHIP_ALT_LOW)
				. = TRUE
			if("med_alt")
				change_altitude(user, SHIP_ALT_MED)
				. = TRUE
		message_admins("[key_name(user)] has changed the ship's altitude to [action].")

	add_fingerprint(user)

/obj/structure/machinery/computer/altitude_control_console/proc/change_altitude(mob/user, new_altitude)
	if(GLOB.ship_alt == new_altitude)
		return
	GLOB.ship_alt = new_altitude
	TIMER_COOLDOWN_START(src, COOLDOWN_ALTITUDE_CHANGE, 40 SECONDS)
	ai_silent_announcement("Attention: Altitude control protocols initialized, currently performing high-g orbital maneuver.", ";", TRUE)
	for(var/mob/living/carbon/current_mob in GLOB.living_mob_list)
		if(!is_mainship_level(current_mob.z))
			continue
		shake_camera(current_mob, 4, 2)
		current_mob.apply_effect(3, SLOW)
		to_chat(user, SPAN_WARNING("You have some difficulty on maintaining balance!"))

#undef COOLING
#undef OVERHEAT_COOLING
#undef HEATING
#undef OVERHEAT
