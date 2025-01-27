#define RESOURCE_INCOME_TELECOMMS 0.15 * UNIVERSAL_TECH_POINTS_MULTIPLICATOR

/obj/structure/machinery/telecomms/relay/preset/tower/mapcomms
	var/datum/techtree/xeno_tree
	var/datum/techtree/marine_tree

/obj/structure/machinery/telecomms/relay/preset/tower/mapcomms/process(delta_time)
	if(!toggled && !corrupted)
		STOP_PROCESSING(SSslowobj, src)
		return

	if(ROUND_TIME < XENO_COMM_ACQUISITION_TIME)
		return
	var/points = RESOURCE_INCOME_TELECOMMS

	var/datum/techtree/tree
	if(corrupted)
		tree = xeno_tree
		points *= UNIVERSAL_XENO_POINTS_MULTIPLICATOR
	else if(toggled)
		tree = marine_tree
		points *= UNIVERSAL_INTEL_POINTS_MULTIPLICATOR

	if(tree)
		tree.comms_income_total += points
		tree.add_points(points)

/obj/structure/machinery/telecomms/relay/preset/tower/mapcomms/New()
	. = ..()
	marine_tree = GET_TREE(TREE_MARINE)
	xeno_tree = GET_TREE(TREE_XENO)

#undef RESOURCE_INCOME_TELECOMMS
