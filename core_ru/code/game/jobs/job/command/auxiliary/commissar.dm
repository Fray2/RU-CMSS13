/datum/job/command/commissar
	title = JOB_COMMISSAR
	total_positions = 1
	spawn_positions = 1
	allow_additional = 1
	scaled = 0
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADMIN_NOTIFY|ROLE_WHITELISTED
	flags_whitelist = WHITELIST_COMMANDER
	gear_preset = /datum/equipment_preset/uscm/commissar
	entry_message_body = "You are an assigned commissioner and are subject to the orders of the Commander of this ship. Your job is to maintain the morale of the Marines on the battlefield, and you are authorized to conduct field executions on the spot."

/obj/effect/landmark/start/uscm_commissar
	name = JOB_COMMISSAR
	job = /datum/job/command/commissar

/datum/job/command/commissar/get_whitelist_status(client/player)
	. = ..()
	if(!.)
		return

	if(player.check_whitelist_status(WHITELIST_COMMANDER))
		return get_desired_status(player.prefs.commander_status, WHITELIST_NORMAL)

