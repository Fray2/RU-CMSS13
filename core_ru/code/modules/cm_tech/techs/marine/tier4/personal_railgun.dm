
/obj/item/storage/box/kit/personal_railgun
	name = "\improper Experimental Personal Railgun(EPR) Kit"
	storage_slots = 3

/obj/item/storage/box/kit/personal_railgun/New()
	..()
	pro_case_overlay = "hmg"

/obj/item/storage/box/kit/personal_railgun/fill_preset_inventory()
	new /obj/item/weapon/gun/rifle/personal_railgun(src)
	new /obj/item/ammo_magazine/personal_railgun/AP(src)
	new /obj/item/ammo_magazine/personal_railgun/HP(src)

/obj/item/weapon/gun/rifle/personal_railgun
	name = "\improper Experimental Personal Railgun"
	desc = "An Experimental railgun capable of being weared in person, IFF excluded, inevadable LETHAL to HUMAN targets."
	icon = 'core_ru/icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "EPR"
	item_state = "EPR"
	item_icons = list(
		WEAR_L_HAND = 'core_ru/icons/mob/humans/onmob/items_lefthand_1.dmi',
		WEAR_R_HAND = 'core_ru/icons/mob/humans/onmob/items_righthand_1.dmi',
		WEAR_BACK = 'core_ru/icons/mob/humans/onmob/back.dmi'
	)
	gun_category = GUN_CATEGORY_HEAVY
	flags_equip_slot = SLOT_BACK|SLOT_BLOCK_SUIT_STORE
	unacidable = TRUE
	explo_proof = TRUE

	w_class = SIZE_LARGE
	fire_sound = 'core_ru/sound/weapons/railgun.ogg'
	current_mag = /obj/item/ammo_magazine/personal_railgun/AP
	force = 12
	wield_delay = WIELD_DELAY_HORRIBLE
	aim_slowdown = SLOWDOWN_ADS_SPECIALIST
	attachable_allowed = list()
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY
	map_specific_decoration = FALSE
	light_system = MOVABLE_LIGHT
	lineart_ru = TRUE

/obj/item/attachable/personal_railgun_barrel
	name = "Experimental Personal Railgun barrel"
	desc = "This isn't supposed to be separated from the gun, how'd this happen?"
	icon = 'core_ru/icons/obj/items/weapons/guns/attachments/barrel.dmi'
	icon_state = "EPR_barrel"
	attach_icon = "EPR_barrel_a"
	slot = "special"
	wield_delay_mod = WIELD_DELAY_NONE
	flags_attach_features = NO_FLAGS
	melee_mod = 0 //Integrated attachment for visuals, stats handled on main gun.
	size_mod = 0

/obj/item/weapon/gun/rifle/personal_railgun/Initialize(mapload, ...)
	. = ..()
	set_light_color("#2059af")
	set_light_range(4)
	set_light_power(1)
	set_light_on(TRUE)

/obj/item/weapon/gun/rifle/personal_railgun/Destroy(mapload, ...)
	set_light_range(null)
	set_light_power(null)
	set_light_on(FALSE)
	return ..()

/obj/item/weapon/gun/rifle/personal_railgun/handle_starting_attachment()
	..()
	var/obj/item/attachable/personal_railgun_barrel/integrated = new(src)
	integrated.flags_attach_features &= ~ATTACH_REMOVABLE
	integrated.Attach(src)
	update_attachable(integrated.slot)

/obj/item/weapon/gun/rifle/personal_railgun/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 43, "muzzle_y" = 17,"rail_x" = 18, "rail_y" = 23, "under_x" = 30, "under_y" = 13, "stock_x" = 24, "stock_y" = 13, "special_x" = 48, "special_y" = 16)
	//оффсэты я не настраивал кроме специального, не должны подходить

/obj/item/weapon/gun/rifle/personal_railgun/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_AMR)
	set_burst_amount(0)
	accuracy_mult = BASE_ACCURACY_MULT + 2*HIT_ACCURACY_MULT_TIER_8
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_8
	recoil = RECOIL_AMOUNT_TIER_3

/obj/item/weapon/gun/rifle/personal_railgun/able_to_fire(mob/living/user)
	. = ..()
	if (. && istype(user)) //Let's check all that other stuff first.
		if(!(((user.job == JOB_SQUAD_SPECIALIST) |( user.job == JOB_SQUAD_LEADER)) | (user.job == JOB_SQUAD_TEAM_LEADER)))
			to_chat(user, SPAN_WARNING("You don't seem to know how to use \the [src]..."))
			to_chat(user, SPAN_WARNING("Only [JOB_SQUAD_SPECIALIST], [JOB_SQUAD_LEADER] and [JOB_SQUAD_TEAM_LEADER] can use \the [src]..."))
			return FALSE
		return TRUE

/obj/item/ammo_magazine/personal_railgun
	name = "\improper Experimental Personal Railgun Ammunition (3 rounds)"
	desc = "A magazine ammo for the poggers Railgun."
	caliber = "14mm"
	icon = 'core_ru/icons/obj/items/weapons/guns/ammo_by_faction/uscm.dmi'
	icon_state = "EPR" //PLACEHOLDER
	w_class = SIZE_MEDIUM
	max_rounds = 3
	default_ammo = /datum/ammo/bullet/sniper/railgun
	gun_type = /obj/item/weapon/gun/rifle/personal_railgun

/obj/item/ammo_magazine/personal_railgun/AP
	name = "\improper Experimental Personal Railgun AP Ammunition (3 rounds)"
	desc = "An AP magazine ammo for the Railgun."
	caliber = "14mm"
	icon_state = "EPR_AP"
	default_ammo = /datum/ammo/bullet/sniper/personal_railgun/AP

/obj/item/ammo_magazine/personal_railgun/HP
	name = "\improper Experimental Personal Railgun HP Ammunition (3 rounds)"
	desc = "A HP magazine ammo for the Railgun."
	caliber = "14mm"
	icon_state = "EPR_HP"
	default_ammo = /datum/ammo/bullet/sniper/personal_railgun/HP

/datum/ammo/bullet/sniper/personal_railgun
	name = "railgun bullet"
	damage_falloff = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SNIPER|AMMO_IGNORE_COVER
	accurate_range_min = 3

	accuracy = HIT_ACCURACY_TIER_8
	accurate_range = 32
	max_range = 32
	scatter = 0
	damage = 2*100
	penetration= ARMOR_PENETRATION_TIER_10
	shell_speed = AMMO_SPEED_TIER_6
	damage_falloff = 0

/datum/ammo/bullet/sniper/personal_railgun/AP
	name = "railgun AP bullet"

	damage = 2.5*100
	penetration= ARMOR_PENETRATION_TIER_10

/datum/ammo/bullet/sniper/personal_railgun/AP/on_hit_mob(mob/M, _unused)
	if(isxeno(M))
		var/mob/living/carbon/xenomorph/X = M
		X.apply_effect(0.4, STUN)
		X.apply_effect(0.4, WEAKEN)
		X.apply_effect(1, SUPERSLOW)
		X.apply_effect(2, SLOW)
	if(ishuman(M))//высокая кинетическая энергия и мне пофиг что не ударило в тело
		var/mob/living/carbon/human/H = M
		H.apply_internal_damage(10, "heart")
		H.apply_internal_damage(10, "lungs")
		H.apply_internal_damage(10, "liver")

/datum/ammo/bullet/sniper/personal_railgun/HP
	name = "railgun HP bullet"
	damage = 3.5*100
	penetration = -ARMOR_PENETRATION_TIER_3 //Очень хреновый урон по бронированным взамен на более внушительное останавливающее действие, ну или разрывное )

/datum/ammo/bullet/sniper/personal_railgun/HP/on_hit_mob(mob/M, _unused)
	if(isxeno(M))
		var/mob/living/carbon/xenomorph/X = M
		X.apply_effect(1, STUN)
		X.apply_effect(1, WEAKEN)
		X.apply_effect(2, SUPERSLOW)
	if(ishuman(M))//высокая кинетическая энергия и мне пофиг что не ударило в тело
		var/mob/living/carbon/human/H = M
		H.apply_internal_damage(20, "heart")
		H.apply_internal_damage(20, "lungs")
		H.apply_internal_damage(20, "liver")

/datum/tech/repeatable/personal_railgun
	name = "Experimental Personal Railguns delivery"
	desc = "Purchase Experimental Personal Railgun kit. Big guns for big problems."
	icon = 'core_ru/icons/effects/techtree/tech.dmi'
	icon_state = "EPR"

	required_points = 20
	increase_per_purchase = 5

	tier = /datum/tier/four/additional

	announce_name = "EXPERIMENTAL ARSENAL ACQUIRED"
	announce_message = "An Experimental Personal Railgun has been authorized and will be delivered to requisitions via ASRS."

	flags = TREE_FLAG_MARINE

/datum/tech/repeatable/personal_railgun/on_unlock()
	. = ..()

	var/datum/supply_order/new_order = new()
	new_order.ordernum = GLOB.supply_controller.ordernum++
	var/actual_type = GLOB.supply_packs_types["Experimental Personal Railgun"]
	new_order.object = GLOB.supply_packs_datums[actual_type]
	new_order.orderedby = MAIN_AI_SYSTEM
	new_order.approvedby = MAIN_AI_SYSTEM

	GLOB.supply_controller.shoppinglist += new_order

/datum/supply_packs/eprk
	name = "Experimental Personal Railgun"
	containername = "Experimental Personal Railgun kit crate"
	contains = list(
		/obj/item/storage/box/kit/personal_railgun,
	)
	cost = 0
	containertype = /obj/structure/closet/crate/supply
	buyable = 0
	group = "Operations"

/datum/tech/repeatable/personal_railgun_AP_delievery
	name = "Experimental Personal Railguns AP magazine delivery"
	desc = "Purchase TWO Experimental Personal Railgun AP magazines. Big guns for big problems."
	icon = 'core_ru/icons/effects/techtree/tech.dmi'
	icon_state = "EPR_AP"

	required_points = 4
	increase_per_purchase = 2

	tier = /datum/tier/four/additional

	announce_name = "EXPERIMENTAL ARSENAL ACQUIRED"
	announce_message = "An Experimental Personal Railgun AP ammo has been authorized and will be delivered to requisitions via ASRS."

	flags = TREE_FLAG_MARINE

/datum/tech/repeatable/personal_railgun_AP_delievery/on_unlock()
	. = ..()

	var/datum/supply_order/new_order = new()
	new_order.ordernum = GLOB.supply_controller.ordernum++
	var/actual_type = GLOB.supply_packs_types["Experimental Personal Railgun AP Ammo"]
	new_order.object = GLOB.supply_packs_datums[actual_type]
	new_order.orderedby = MAIN_AI_SYSTEM
	new_order.approvedby = MAIN_AI_SYSTEM

	GLOB.supply_controller.shoppinglist += new_order

/datum/supply_packs/eprAP
	name = "Experimental Personal Railgun AP Ammo"
	containername = "Experimental Personal Railgun AP magazine crate"
	contains = list(
		/obj/item/ammo_magazine/personal_railgun/AP,
		/obj/item/ammo_magazine/personal_railgun/AP,
	)
	cost = 0
	containertype = /obj/structure/closet/crate/ammo
	buyable = 0
	group = "Operations"

/datum/tech/repeatable/personal_railgun_HP_delievery
	name = "Experimental Personal Railguns HP magazine delivery"
	desc = "Purchase TWO Experimental Personal Railgun HP magazine. Big guns for big problems."
	icon = 'core_ru/icons/effects/techtree/tech.dmi'
	icon_state = "EPR_HP"

	required_points = 4
	increase_per_purchase = 2

	tier = /datum/tier/four/additional

	announce_name = "EXPERIMENTAL ARSENAL ACQUIRED"
	announce_message = "An Experimental Personal Railgun HP ammo has been authorized and will be delivered to requisitions via ASRS."

	flags = TREE_FLAG_MARINE

/datum/tech/repeatable/personal_railgun_HP_delievery/on_unlock()
	. = ..()

	var/datum/supply_order/new_order = new()
	new_order.ordernum = GLOB.supply_controller.ordernum++
	var/actual_type = GLOB.supply_packs_types["Experimental Personal Railgun HP Ammo"]
	new_order.object = GLOB.supply_packs_datums[actual_type]
	new_order.orderedby = MAIN_AI_SYSTEM
	new_order.approvedby = MAIN_AI_SYSTEM

	GLOB.supply_controller.shoppinglist += new_order

/datum/supply_packs/personal_railgun_HP
	name = "Experimental Personal Railgun HP Ammo"
	containername = "Experimental Personal Railgun HP magazine crate"
	contains = list(
		/obj/item/ammo_magazine/personal_railgun/HP,
		/obj/item/ammo_magazine/personal_railgun/HP,
	)
	cost = 0
	containertype = /obj/structure/closet/crate/ammo
	buyable = 0
	group = "Operations"
