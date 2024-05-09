/mob/verb/battlepass()
	set category = "OOC"
	set name = "Battlepass"

	if(!client)
		return

	if(!SSbattlepass.initialized)
		return

	client.owned_battlepass?.ui_interact(src)

/mob/living/carbon/verb/claim_battlepass_reward()
	set category = "OOC"
	set name = "Claim Battlepass Reward"

	if(!client)
		return

	var/list/acceptable_rewards = list()
	for(var/datum/battlepass_reward/reward as anything in client.owned_battlepass.rewards)
		if(reward.can_claim(src))
			acceptable_rewards += reward

	if(!length(acceptable_rewards))
		to_chat(src, SPAN_WARNING("You have no rewards to claim."))
		return

	var/datum/battlepass_reward/chosen_reward = tgui_input_list(src, "Claim a battlepass reward.", "Claim Reward", acceptable_rewards)
	if(!chosen_reward || !chosen_reward.can_claim(src))
		return

	if(chosen_reward.on_claim(src))
		claimed_reward_categories |= chosen_reward.category

/mob/var/obj/effect/abstract/particle_holder/particle_holder

/// Each client possesses an instanced /datum/battlepass
/datum/battlepass
	/// The current battlepass tier the user is at
	/// Max tier is stored on the master battlepass the server owns
	var/tier = 1

	/// How much XP the user has in the current tier
	var/xp = 0

	/// How much XP you need to go up a tier
	var/xp_tierup = 10

	// If the user has paid for a premium battlepass
	//var/premium = FALSE // (:

	/// List of personal daily challenges
	var/list/datum/battlepass_challenge/daily_challenges = list()

	/// When challenges were last updated, formatted as a UNIX timestamp
	var/daily_challenges_last_updated = 0

	/// Weakref to the owning client
	var/datum/weakref/owning_client

	/// All earned battlepass reward instances
	var/list/datum/battlepass_reward/rewards = list()

	/// Typepaths of all earned battlepass rewards. This isn't saved because it's populated by loading the rewards list
	var/list/reward_paths = list()

	/// The tier of the battlepass the last time on_tier_up() was called
	var/previous_on_tier_up_tier = 0

/datum/battlepass/proc/add_xp(xp_amount)
	if(tier >= SSbattlepass.maximum_tier)
		return

	xp += xp_amount
	check_tier_up(TRUE)

/datum/battlepass/proc/check_tier_up(display_popup = TRUE)
	if(xp >= xp_tierup)
		var/tier_increase = round(xp / xp_tierup)
		xp -= (tier_increase * xp_tierup)
		tier += tier_increase
		on_tier_up(display_popup)
	update_static_data_for_all_viewers()

/datum/battlepass/proc/on_tier_up(display_popup = TRUE)
	if(previous_on_tier_up_tier == tier)
		return

	for(var/i in previous_on_tier_up_tier + 1 to tier)
		var/reward_path = SSbattlepass.season_rewards[i]
		var/datum/battlepass_reward/reward = new reward_path
		rewards += reward
		reward_paths += reward_path

	if(display_popup)
		display_tier_up_popup()

	var/list/types_in_rewards = list()
	for(var/datum/battlepass_reward/reward as anything in rewards)
		if(reward.type in types_in_rewards)
			rewards -= reward
			reward_paths -= reward.type
			qdel(reward)
			continue

		types_in_rewards += reward.type

	previous_on_tier_up_tier = tier
	var/client/oc = owning_client.resolve()
	log_game("[oc.mob] ([oc.key]) has increased to battlepass tier [tier]")

/datum/battlepass/proc/display_tier_up_popup()
	if(!owning_client)
		return

	var/client/user_client = owning_client.resolve()
	if(!user_client.mob)
		return

	playsound_client(user_client, 'fray-marines/sound/effects/bp_levelup.mp3', get_turf(user_client.mob), 70, FALSE) // .mp3, sue me
	user_client.mob.overlay_fullscreen("battlepass_tierup", /atom/movable/screen/fullscreen/battlepass)
	addtimer(CALLBACK(user_client.mob, TYPE_PROC_REF(/mob, clear_fullscreen), "battlepass_tierup", 0), 1.2 SECONDS)

/// Check that the user has all the rewards they should (in case rewards shifted in config or etc).
/// Doesn't remove ones that aren't in their tiers (in case they have some from a previous season, for example)
/datum/battlepass/proc/verify_rewards()
	for(var/i = 1 to tier)
		if(SSbattlepass.season_rewards.len < i)
			break
		var/reward_path = SSbattlepass.season_rewards[i]
		if(reward_path in reward_paths)
			continue

		rewards += new reward_path
		reward_paths += reward_path

/// Check if it's been 24h since daily challenges were last assigned
/datum/battlepass/proc/check_daily_challenge_reset()
	// Clients can connect before the SS is initialized
	if(!SSbattlepass?.initialized)
		return

	// 86400 seconds (24*60^2) is one day
	if((daily_challenges_last_updated + (24 * 60 * 60)) <= rustg_unix_timestamp())
		reset_daily_challenges()
		return TRUE
	return FALSE

/// Give the battlepass a new set of daily challenges
/datum/battlepass/proc/reset_daily_challenges()
	if(!owning_client)
		return

	// We give the player 2 marine challenges and 2 xeno challenges
	QDEL_LIST(daily_challenges)

	for(var/i in 1 to 2)
		var/gotten_path = SSbattlepass.get_challenge(CHALLENGE_HUMAN)
		var/datum/battlepass_challenge/human_challenge = new gotten_path(owning_client.resolve())
		RegisterSignal(human_challenge, COMSIG_BATTLEPASS_CHALLENGE_COMPLETED, PROC_REF(on_challenge_complete))
		daily_challenges += human_challenge

	for(var/i in 1 to 2)
		var/gotten_path = SSbattlepass.get_challenge(CHALLENGE_XENO)
		var/datum/battlepass_challenge/xeno_challenge = new gotten_path(owning_client.resolve())
		RegisterSignal(xeno_challenge, COMSIG_BATTLEPASS_CHALLENGE_COMPLETED, PROC_REF(on_challenge_complete))
		daily_challenges += xeno_challenge

	daily_challenges_last_updated = rustg_unix_timestamp()

/// Returns a list of all daily challenges formatted for a savefile
/datum/battlepass/proc/serialize_daily_challenges()
	. = list()
	for(var/datum/battlepass_challenge/challenge as anything in daily_challenges)
		. += list(challenge.serialize())

/datum/battlepass/proc/serialize_rewards()
	. = list()
	var/list/saved_reward_paths = list()
	for(var/datum/battlepass_reward/reward as anything in rewards)
		if(reward.type in saved_reward_paths)
			continue

		. += reward.type
		saved_reward_paths += reward.type

/// Provided a list of lists for daily challenges, load daily challenges from the lists
/datum/battlepass/proc/load_daily_challenges(list/challenge_data)
	if(!owning_client)
		return

	for(var/list/entry as anything in challenge_data)
		if(!("type" in entry))
			continue

		var/path = entry["type"]
		var/datum/battlepass_challenge/challenge = new path(owning_client.resolve())
		daily_challenges += challenge
		RegisterSignal(challenge, COMSIG_BATTLEPASS_CHALLENGE_COMPLETED, PROC_REF(on_challenge_complete))
		challenge.deserialize(entry)

/datum/battlepass/proc/load_rewards(list/reward_data)
	var/list/loaded_paths = list()
	for(var/path in reward_data)
		if(path in loaded_paths)
			continue

		var/datum/battlepass_reward/reward = new path
		rewards += reward
		reward_paths += path
		loaded_paths += path

/// Called whenever a challenge is completed
/datum/battlepass/proc/on_challenge_complete(datum/battlepass_challenge/challenge)
	SIGNAL_HANDLER

	if(!owning_client)
		return

	var/client/resolved_client = owning_client.resolve()
	challenge.completed = TRUE
	add_xp(challenge.completion_xp)
	challenge.unhook_signals(resolved_client.mob)

/datum/battlepass/proc/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Battlepass")
		ui.open()

/datum/battlepass/ui_state(mob/user)
	return GLOB.always_state

/datum/battlepass/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/battlepass),
	)

/datum/battlepass/ui_data(mob/user)
	var/list/data = list()

	data["tier"] = tier
	data["xp"] = tier >= SSbattlepass.maximum_tier ? xp_tierup : xp
	data["xp_tierup"] = xp_tierup

	return data

/datum/battlepass/ui_static_data(mob/user)
	var/list/data = list()

	data["season"] = SSbattlepass.season
	data["max_tier"] = SSbattlepass.maximum_tier

	data["rewards"] = list()

	var/i = 1
	for(var/datum/battlepass_reward/reward_path as anything in SSbattlepass.season_rewards)
		data["rewards"] += list(list(
			"name" = initial(reward_path.name),
			"icon_state" = initial(reward_path.icon_state),
			"tier" = i,
			"lifeform_type" = initial(reward_path.lifeform_type),
		))
		i++

	data["premium_rewards"] = list()

	i = 1
	for(var/datum/battlepass_reward/reward_path as anything in SSbattlepass.premium_season_rewards)
		data["premium_rewards"] += list(list(
			"name" = initial(reward_path.name),
			"icon_state" = initial(reward_path.icon_state),
			"tier" = i,
			"lifeform_type" = initial(reward_path.lifeform_type),
		))
		i++

	data["daily_challenges"] = list()

	for(var/datum/battlepass_challenge/daily_challenge as anything in daily_challenges)
		data["daily_challenges"] += list(list(
			"name" = daily_challenge.name,
			"desc" = daily_challenge.desc,
			"completed" = daily_challenge.completed,
			"category" = daily_challenge.challenge_category,
			"completion_xp" = daily_challenge.completion_xp,
			"completion_percent" = daily_challenge.get_completion_percent(),
			"completion_numerator" = daily_challenge.get_completion_numerator(),
			"completion_denominator" = daily_challenge.get_completion_denominator(),
		))

	return data

/datum/battlepass/vv_edit_var(var_name, var_value)
	if(usr.ckey != "zonespace")
		to_chat(usr, SPAN_BOLDWARNING("FUCK OFF"))
		return FALSE
	return ..()
