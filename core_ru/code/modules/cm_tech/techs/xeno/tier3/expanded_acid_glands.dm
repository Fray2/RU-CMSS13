/datum/tech/xeno/expanded_glands
	name = "Expanded Acidic Glands Evolution"
	desc = "Expanding Acidic Glands ways, improving ONLY acidic spits damage, penetration and acid speed at the cost of plasma."
	icon = 'core_ru/icons/effects/techtree/tech.dmi'
	icon_state = "expanded_glands"

	flags = TREE_FLAG_XENO

	required_points = 8
	tier = /datum/tier/three/additional

	var/acid_damage_mult = 1.25
	var/acid_penetration = 5
	var/acid_speed_bonus = 1
	var/plasma_cost_increase = 2

/datum/tech/xeno/expanded_glands/ui_static_data(mob/user)
	. = ..()
	.["stats"] += list(
		list(
			"content" = "Acid Spit Damage Increase: +[(acid_damage_mult-1)*100]%",
			"color" = "xeno",
			"icon" = "biohazard"
		)
	)
	.["stats"] += list(
		list(
			"content" = "Acid Spit Penetration Increase: +[acid_penetration]",
			"color" = "xeno",
			"icon" = "biohazard"
		)
	)
	.["stats"] += list(
		list(
			"content" = "Acid Spit speed Increase: +[acid_speed_bonus]",
			"color" = "xeno",
			"icon" = "biohazard"
		)
	)
	.["stats"] += list(
		list(
			"content" = "Acid spit Plasma Cost Increase: +[(plasma_cost_increase-1)*100]%",
			"color" = "red",
			"icon" = "bomb"
		)
	)

/datum/tech/xeno/expanded_glands/on_unlock(datum/techtree/tree)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_XENO_SPAWN, .proc/register_component)

	for(var/m in hive.totalXenos)
		register_component(src, m)

/datum/tech/xeno/expanded_glands/proc/register_component(datum/source, mob/living/carbon/xenomorph/X)
	SIGNAL_HANDLER
	if(X.hivenumber == hivenumber)
		RegisterSignal(X, COMSIG_XENO_PRE_SPIT, .proc/handle_acid_spit)

/datum/tech/xeno/expanded_glands/proc/handle_acid_spit(mob/living/carbon/xenomorph/X, list/ammospit) //just ammo tries to modify xeno damage stacking itself
	SIGNAL_HANDLER
	ammospit["damage"] *= acid_damage_mult
	ammospit["penetration"] += acid_penetration
	ammospit["shell_speed"] += acid_speed_bonus
	ammospit["spit_cost"] *= plasma_cost_increase
