/datum/tech/xeno/powerup/health_up
	name = "HealthUP!"
	desc = "Strengthens hide of xeno for more survival rate. Increases max health for xeno and instantly heal xeno"
	icon = 'fray-marines/icons/effects/techtree/tech.dmi'
	icon_state = "healthup"

	flags = TREE_FLAG_XENO

	required_points = 5
	increase_per_purchase = 1
	xenos_required = FALSE
	tier = /datum/tier/four

/datum/tech/xeno/powerup/health_up/on_unlock(datum/techtree/tree)
	. = ..()
	hive.healthstack += 0.1

	for(var/mob/living/carbon/xenomorph/X as anything in hive.totalXenos)
		X.recalculate_health()
