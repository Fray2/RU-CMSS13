/obj/effect
	icon = 'icons/effects/effects.dmi'
	blocks_emissive = EMISSIVE_BLOCK_GENERIC

	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_LAYER|VIS_INHERIT_PLANE

	var/as_image = FALSE

/obj/effect/get_applying_acid_time()
	return -1
