//// Powers used by multiple Xenomorphs.
// In general, powers files hold actual implementations of abilities,
// and abilities files hold the object declarations for the abilities

/datum/action/xeno_action/activable/xeno_spit/use_ability(atom/atom)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/spit_target = aim_turf ? get_turf(atom) : atom
	if(!xeno.check_state())
		return

	if(spitting)
		to_chat(src, SPAN_WARNING("We are already preparing a spit!"))
		return

	if(!isturf(xeno.loc))
		to_chat(src, SPAN_WARNING("We can't spit from here!"))
		return

	if(!action_cooldown_check())
		to_chat(src, SPAN_WARNING("We must wait for our spit glands to refill."))
		return

	var/turf/current_turf = get_turf(xeno)

	if(!current_turf)
		return

	if (!check_plasma_owner())
		return

	if(xeno.ammo.spit_windup)
		spitting = TRUE
		if(xeno.ammo.pre_spit_warn)
			playsound(xeno.loc,"alien_drool", 55, 1)
		to_chat(xeno, SPAN_WARNING("We begin to prepare a large spit!"))
		xeno.visible_message(SPAN_WARNING("[xeno] prepares to spit a massive glob!"),\
		SPAN_WARNING("We begin to spit [xeno.ammo.name]!"))
		if (!do_after(xeno, xeno.ammo.spit_windup, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_HOSTILE))
			to_chat(xeno, SPAN_XENODANGER("We decide to cancel our spit."))
			spitting = FALSE
			return
	var/list/new_vars = list("damage" = xeno.ammo.damage, "penetration" = xeno.ammo.penetration, "shell_speed" = xeno.ammo.shell_speed, "spit_cost" = xeno.ammo.spit_cost)
	SEND_SIGNAL(xeno, COMSIG_XENO_PRE_SPIT, new_vars)
	var/datum/ammo/xeno/new_ammo = new xeno.ammo.type
	new_ammo.damage = new_vars["damage"]
	new_ammo.penetration = new_vars["penetration"]
	new_ammo.shell_speed = new_vars["shell_speed"]
	new_ammo.spit_cost = new_vars["spit_cost"]
	plasma_cost = new_ammo.spit_cost

	if(!check_and_use_plasma_owner())
		spitting = FALSE
		return

	xeno_cooldown = xeno.caste.spit_delay + xeno.ammo.added_spit_delay
	xeno.visible_message(SPAN_XENOWARNING("[xeno] spits at [atom]!"), \

	SPAN_XENOWARNING("We spit [xeno.ammo.name] at [atom]!") )
	playsound(xeno.loc, sound_to_play, 25, 1)

	var/obj/projectile/proj = new (current_turf, create_cause_data(xeno.ammo.name, xeno))
	proj.generate_bullet(new_ammo)
	proj.permutated += xeno
	proj.def_zone = xeno.get_limbzone_target()
	proj.fire_at(spit_target, xeno, xeno, new_ammo.max_range, new_ammo.shell_speed)

	spitting = FALSE

	SEND_SIGNAL(xeno, COMSIG_XENO_POST_SPIT)

	apply_cooldown()
	return ..()
