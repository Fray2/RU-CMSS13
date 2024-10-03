GLOBAL_LIST_EMPTY(arena_spawn_landmarks)
GLOBAL_VAR_INIT(arena_active, TRUE)

/proc/drop_to_arena(client/target_client)
	var/turf/spawn_loc = get_turf(pick(GLOB.arena_spawn_landmarks))
	var/datum/mind/target_mind = target_client.mob?.mind
	var/timeofdeath = target_client.mob.timeofdeath
	if(!timeofdeath)
		timeofdeath = world.time
	if(!target_mind)
		target_client.mob.mind = new /datum/mind(target_client.key, target_client.ckey)
		target_client.mob.mind_initialize()
		target_mind = target_client.mob.mind

	if(prob(10))
		var/mob/living/carbon/human/human = new(spawn_loc)
		target_mind.transfer_to(human, TRUE)
		if(prob(10)) // only 1 out of 10 can be pred
			var/datum/job/J = GLOB.RoleAuthority.roles_by_name[JOB_PREDATOR]
			if(!J)
				human.Alienize(ALL_XENO_CASTES) // no balls, no luck, no shit
				GLOB.hive_datum[XENO_HIVE_FERAL].add_xeno(target_client.mob)
			else
				GLOB.RoleAuthority.equip_role(human, J, human.loc)
		else
			human.Alienize(ALL_XENO_CASTES)
			GLOB.hive_datum[XENO_HIVE_FERAL].add_xeno(target_client.mob)
	else
		var/mob/living/carbon/human/human = new(spawn_loc)
		target_mind.transfer_to(human, TRUE)
		arm_equipment(human, pick(GLOB.gear_path_presets_list), TRUE, FALSE)
	//Self signal registration, because reg on client or something else is bad idea
	target_client.mob.RegisterSignal(target_client.mob, COMSIG_MOB_GHOSTIZE, GLOBAL_PROC_REF(set_right_timeofdeath), timeofdeath)

/proc/set_right_timeofdeath(mob/source, real_timeofdeath)
	set waitfor = FALSE
	// Funny fuckery
	var/client/target_client = source.client
	sleep(1) // Give time for a shitty cm code to do their fuckery around with timeofdeath and set it to 1 or right now, and then we place a real one
	target_client.mob.timeofdeath = real_timeofdeath

/obj/effect/landmark/spawn_arena
	name = "arena"

/obj/effect/landmark/spawn_arena/Initialize(mapload, ...)
	. = ..()
	GLOB.arena_spawn_landmarks += src

/obj/effect/landmark/spawn_arena/Destroy()
	GLOB.arena_spawn_landmarks -= src
	return ..()


/mob/dead/verb/join_death_match_arena()
	set category = "Ghost.Join"
	set name = "Join Death Match Arena"
	set desc = "You will be teleported to admin zone and having fun while waiting death timer."

	if(!client)
		return

	if(SSticker.current_state < GAME_STATE_PLAYING || !SSticker.mode)
		to_chat(src, SPAN_WARNING("The game hasn't started yet!"))
		return

	if(!GLOB.arena_active)
		to_chat(src, SPAN_WARNING("Arena disabled!"))
		return

	drop_to_arena(client)

