
/datum/action/xeno_action/activable/warrior_punch/proc/do_mech_warrior_punch(obj/vehicle/walker/walker)
	var/mob/living/carbon/xenomorph/warrior = owner
	var/damage = rand(base_damage, base_damage + damage_variance)

	if(istype(walker))
		damage*=4
		walker.health = max(0, walker.health - damage)
		walker.healthcheck()
		warrior.face_atom(walker)
		warrior.animation_attack_on(walker)
		warrior.flick_attack_overlay(walker, "punch")
