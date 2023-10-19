

/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "Object"
	set src = usr

	if (usr.is_mob_incapacitated())
		return

	if(hand)
		var/obj/item/W = l_hand
		if (W)
			W.attack_self(src)
			update_inv_l_hand()
	else
		var/obj/item/W = r_hand
		if (W)
			W.attack_self(src)
			update_inv_r_hand()
	if(next_move < world.time)
		next_move = world.time + 2
	return

/mob/verb/toggle_normal_throw()
	set name = "Toggle Normal Throw"
	set category = "IC"
	set hidden = TRUE
	set src = usr

	to_chat(usr, SPAN_DANGER("This mob type cannot throw items."))
	return

/mob/verb/view_stats()
	set category = "OOC"
	set name = "View Playtimes"
	set desc = "View your playtimes."
	if(!SSentity_manager.ready)
		to_chat(src, "DB is still starting up, please wait")
		return
	if(client && client.player_entity)
		client.player_data.tgui_interact(src)

/mob/verb/toggle_high_toss()
	set name = "Toggle High Toss"
	set category = "IC"
	set hidden = TRUE
	set src = usr

	to_chat(usr, SPAN_DANGER("This mob type cannot throw items."))
	return

/mob/proc/point_to(atom/A in view())
	//set name = "Point To"
	//set category = "Object"

	if(!isturf(src.loc) || !(A in view(src)))//target is no longer visible to us
		return 0

	if(!A.mouse_opacity)//can't click it? can't point at it.
		return 0

	if(is_mob_incapacitated() || (status_flags & FAKEDEATH)) //incapacitated, can't point
		return 0

	var/tile = get_turf(A)
	if (!tile)
		return 0

	if(recently_pointed_to > world.time)
		return 0

	next_move = world.time + 2

	point_to_atom(A, tile)
	return 1





/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	if(mind)
		mind.show_memory(src)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)

	if(mind)
		if(length(mind.memory) < 4000)
			mind.store_memory(msg)
		else
			src.sleeping = 9999999
			message_admins("[key_name(usr)] auto-slept for attempting to exceed mob memory limit. [ADMIN_JMP(src.loc)]")
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

//Больше никаких блатных респаунов администраторам
//	var/is_admin = 0
//	if(client.admin_holder && (client.admin_holder.rights & R_ADMIN))
//		is_admin = 1

//	if (!CONFIG_GET(flag/respawn) && !is_admin)
//		to_chat(usr, SPAN_NOTICE(" Respawn is disabled."))
//		return
	var/datum/game_mode/G = SSticker.mode
	if (stat != 2)
		to_chat(usr, SPAN_NOTICE(" <B>You must be dead to use this!</B>"))
		return
	if (SSticker.mode && (SSticker.mode.name == "meteor" || SSticker.mode.name == "epidemic")) //BS12 EDIT
		to_chat(usr, SPAN_NOTICE(" Respawn is disabled for this roundtype."))
		return
	if (!isobserver(src))
		to_chat(usr, SPAN_NOTICE(" You must ghost to do this."))
		return
	else
		var/deathtime = world.time - src.timeofdeath
		var/deathtimeminutes = round(deathtime / 600)
		var/pluralcheck = "minute"
		if(deathtimeminutes == 0)
			pluralcheck = ""
		else if(deathtimeminutes == 1)
			pluralcheck = " [deathtimeminutes] minute and"
		else if(deathtimeminutes > 1)
			pluralcheck = " [deathtimeminutes] minutes and"
		var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)
		to_chat(usr, "You have been dead for[pluralcheck] [deathtimeseconds] seconds.")
		if(G.respawns_available <= 0)
			to_chat(usr, "Players have used all respawn points for this game.")
		if(world.time <= src.timeofdeath + 20 MINUTES) //20 минут
//		if(world.time <= src.timeofdeath + 10 SECONDS) //10 сек (для тестов)
			to_chat(usr, "Respawn is available after 20 minutes.")
			return

	if(alert("Are you sure you want to respawn as a squad marine?",,"Yes","No") != "Yes")
		return

	G.respawns_available -= 1
	for(var/mob/dead/observer/observer as anything in GLOB.observer_list)
		to_chat(observer, SPAN_DEADSAY(FONT_SIZE_LARGE("Respawn points available: [G.respawns_available]")))

	log_game("[usr.name]/[usr.key] used respawn button.")

	SSticker.mode.attempt_to_join_as_rifleman(usr)
// M.Login() //wat
//	return

/mob/dead/observer/verb/observe()
	set name = "Observe"
	set category = "Ghost"

	reset_perspective(null)

	var/mob/target = tgui_input_list(usr, "Please select a human mob:", "Observe", GLOB.human_mob_list)
	if(!target)
		return

	do_observe(target)

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "Object"
	reset_view(null)
	unset_interaction()
	if(istype(src, /mob/living))
		var/mob/living/M = src
		if(M.cameraFollow)
			M.cameraFollow = null

/mob/verb/eastface()
	set hidden = TRUE
	return face_dir(EAST)

/mob/verb/westface()
	set hidden = TRUE
	return face_dir(WEST)

/mob/verb/northface()
	set hidden = TRUE
	return face_dir(NORTH)

/mob/verb/southface()
	set hidden = TRUE
	return face_dir(SOUTH)


/mob/verb/northfaceperm()
	set hidden = TRUE
	set_face_dir(NORTH)

/mob/verb/southfaceperm()
	set hidden = TRUE
	set_face_dir(SOUTH)

/mob/verb/eastfaceperm()
	set hidden = TRUE
	set_face_dir(EAST)

/mob/verb/westfaceperm()
	set hidden = TRUE
	set_face_dir(WEST)



/mob/verb/stop_pulling()

	set name = "Stop Pulling"
	set category = "IC"

	if(pulling)
		var/mob/M = pulling
		pulling.pulledby = null
		pulling = null

		grab_level = 0
		if(client)
			client.recalculate_move_delay()
			// When you stop pulling a mob after you move a tile with it your next movement will still include
			// the grab delay so we have to fix it here (we love code)
			client.next_movement = world.time + client.move_delay
		if(hud_used && hud_used.pull_icon)
			hud_used.pull_icon.icon_state = "pull0"
		if(istype(r_hand, /obj/item/grab))
			temp_drop_inv_item(r_hand)
		else if(istype(l_hand, /obj/item/grab))
			temp_drop_inv_item(l_hand)
		if(istype(M))
			if(M.client)
				//resist_grab uses long movement cooldown durations to prevent message spam
				//so we must undo it here so the victim can move right away
				M.client.next_movement = world.time
			M.update_transform(TRUE)
			M.update_canmove()
