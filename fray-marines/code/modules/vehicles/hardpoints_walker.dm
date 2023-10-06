////////////////
// MEGALODON HARDPOINTS // START
////////////////

/obj/item/walker_gun
	name = "walker gun"
	icon = 'fray-marines/icons/obj/vehicles/mecha_guns.dmi'
	var/equip_state = ""
	w_class = 12.0
	var/obj/vehicle/walker/owner = null
	var/magazine_type = /obj/item/ammo_magazine/walker
	var/obj/item/ammo_magazine/walker/ammo = null
	var/list/fire_sound = list('sound/weapons/gun_smartgun1.ogg', 'sound/weapons/gun_smartgun2.ogg', 'sound/weapons/gun_smartgun3.ogg')
	var/fire_delay = 0
	var/last_fire = 0
	var/burst = 1

	w_class = 12.0

	var/muzzle_flash 	= "muzzle_flash"
	var/muzzle_flash_lum = 3 //muzzle flash brightness
	var/list/projectile_traits = list()

/obj/item/walker_gun/Initialize()
	. = ..()

	ammo = new magazine_type()

/obj/item/walker_gun/proc/get_icon_image(hardpoint)
	if(!owner)
		return

	return image(owner.icon, equip_state + hardpoint)

/obj/item/walker_gun/proc/active_effect(atom/target)
	if (!ammo)
		to_chat(owner.seats[VEHICLE_DRIVER], "<span class='warning'>WARNING! System report: ammunition is depleted!</span>")
		return
	if(ammo.current_rounds <= 0)
		to_chat(owner.seats[VEHICLE_DRIVER], "<span class='warning'>WARNING! System report: ammunition is depleted!</span>")
		ammo.loc = owner.loc
		ammo = null
		visible_message("[owner.name]'s systems deployed used magazine.","")
		return
	if(world.time < last_fire + fire_delay)
		to_chat(owner.seats[VEHICLE_DRIVER], "<span class='warning'>WARNING! System report: weapon is not ready to fire again!</span>")
		return
	last_fire = world.time
	var/obj/projectile/P
	for(var/i = 1 to burst)
		if(!owner.firing_arc(target))
			if(i == 1)
				return
			to_chat(owner.seats[VEHICLE_DRIVER] , "<span class='warning'>[name] fired! [ammo.current_rounds]/[ammo.max_rounds] remaining!")
			visible_message("<span class='danger'>[owner.name] fires from [name]!</span>", "<span class='warning'>You hear [istype(P.ammo, /datum/ammo/bullet) ? "gunshot" : "blast"]!</span>")
			return
		P = new
		P.generate_bullet(new ammo.default_ammo)
		for (var/trait in projectile_traits)
			GIVE_BULLET_TRAIT(P, /datum/element/bullet_trait_iff, FACTION_MARINE)
		playsound(get_turf(owner), pick(fire_sound), 60)
		target = simulate_scatter(target, P)
		P.fire_at(target, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		ammo.current_rounds--
		if(ammo.current_rounds <= 0)
			ammo.loc = owner.loc
			ammo = null
			visible_message("[owner.name]'s systems deployed used magazine.","")
			break
		sleep(3)
	to_chat(owner.seats[VEHICLE_DRIVER] , "<span class='warning'>[name] fired! [ammo.current_rounds]/[ammo.max_rounds] remaining!")
	visible_message("<span class='danger'>[owner.name] fires from [name]!</span>", "<span class='warning'>You hear [istype(P.ammo, /datum/ammo/bullet) ? "gunshot" : "blast"]!</span>")

	var/angle = round(Get_Angle(owner,target))
	muzzle_flash(angle)

	if(ammo.current_rounds <= 0)
		ammo.loc = owner.loc
		ammo = null
		visible_message("[owner.name]'s systems deployed used magazine.","")
	return TRUE

/obj/item/walker_gun/proc/muzzle_flash(angle, x_offset = -9, y_offset = 5)
	if(!muzzle_flash ||  isnull(angle))
		return //We have to check for null angle here, as 0 can also be an angle.
	if(!istype(owner) || !istype(owner.loc,/turf))
		return

	var/prev_light = light_range
	if(!light_on && (light_range <= muzzle_flash_lum))
		set_light_range(muzzle_flash_lum)
		set_light_on(TRUE)
		addtimer(CALLBACK(src, PROC_REF(reset_light_range), prev_light), 0.5 SECONDS)

	var/image_layer = (owner && owner.dir == SOUTH) ? MOB_LAYER+0.1 : MOB_LAYER-0.1
	var/offset = 5

	var/image/I = image('icons/obj/items/weapons/projectiles.dmi',owner,muzzle_flash,image_layer)
	var/matrix/rotate = matrix() //Change the flash angle.
	rotate.Translate(0, offset)
	rotate.Turn(angle)
	I.transform = rotate
	I.flick_overlay(owner, 3)

/// called by a timer to remove the light range from muzzle flash
/obj/item/walker_gun/proc/reset_light_range(lightrange)
	set_light_range(lightrange)
	if(lightrange <= 0)
		set_light_on(FALSE)

/obj/item/walker_gun/proc/simulate_scatter(atom/target, obj/projectile/projectile_to_fire)
	var/fire_angle = Get_Angle(owner.loc, get_turf(target))
	var/total_scatter_angle = projectile_to_fire.scatter - rand(-5,5)

	//Not if the gun doesn't scatter at all, or negative scatter.
	if(total_scatter_angle > 0)
		fire_angle += rand(-total_scatter_angle, total_scatter_angle)
		target = get_angle_target_turf(owner.loc, fire_angle, 30)

	return get_turf(target)


/obj/item/walker_gun/smartgun
	name = "M56 Double-Barrel Mounted Smartgun"
	desc = "Modifyed version of standart USCM Smartgun System, mounted on military walkers"
	icon_state = "mech_smartgun_parts"
	equip_state = "redy_smartgun"
	magazine_type = /obj/item/ammo_magazine/walker/smartgun
	burst = 2
	fire_delay = 13

	projectile_traits = list("iff")

/obj/item/walker_gun/hmg
	name = "M30 Machine Gun"
	desc = "High-caliber machine gun firing small bursts of AP bullets, tearing into shreds unfortunate fellas on its way."
	icon_state = "mech_minigun_parts"
	equip_state = "redy_minigun"
	fire_sound = list('sound/weapons/gun_minigun.ogg')
	magazine_type = /obj/item/ammo_magazine/walker/hmg
	fire_delay = 20
	burst = 3

/obj/item/walker_gun/flamer
	name = "F40 \"Hellfire\" Flamethower"
	desc = "Powerful flamethower, that can send any unprotected target straight to hell."
	icon_state = "mech_flamer_parts"
	equip_state = "redy_flamer"
	fire_sound = 'sound/weapons/gun_flamethrower2.ogg'
	magazine_type = /obj/item/ammo_magazine/walker/flamer
	var/fuel_pressure = 1 //Pressure setting of the attached fueltank, controls how much fuel is used per tile
	var/max_range = 9 //9 tiles, 7 is screen range, controlled by the type of napalm in the canister. We max at 9 since diagonal bullshit.
	fire_delay = 4 SECONDS

/obj/item/walker_gun/flamer/proc/get_fire_sound()
	var/list/fire_sounds = list(
							'sound/weapons/gun_flamethrower1.ogg',
							'sound/weapons/gun_flamethrower2.ogg',
							'sound/weapons/gun_flamethrower3.ogg')
	return pick(fire_sounds)

/obj/item/walker_gun/flamer/active_effect(atom/target)
	if (!ammo)
		to_chat(owner.seats[VEHICLE_DRIVER], "<span class='warning'>WARNING! System report: ammunition is depleted!</span>")
		return
	if(ammo.current_rounds <= 0)
		to_chat(owner.seats[VEHICLE_DRIVER], "<span class='warning'>WARNING! System report: ammunition is depleted!</span>")
		ammo.loc = owner.loc
		ammo = null
		visible_message("[owner.name]'s systems deployed used magazine.","")
		return
	if(world.time < last_fire + fire_delay)
		to_chat(owner.seats[VEHICLE_DRIVER], "<span class='warning'>WARNING! System report: weapon is not ready to fire again!</span>")
		return
	last_fire = world.time
	if(!ammo.reagents.reagent_list.len)
		to_chat(owner.seats[VEHICLE_DRIVER], "<span class='warning'>WARNING! System report: ammunition is depleted!</span>")
		ammo.loc = owner.loc
		ammo = null
		visible_message("[owner.name]'s systems deployed used magazine.")
		return

	var/datum/reagent/R = ammo.reagents.reagent_list[1]

	var/flameshape = R.flameshape
	var/fire_type = R.fire_type

	R.intensityfire = Clamp(R.intensityfire, ammo.reagents.min_fire_int, ammo.reagents.max_fire_int)
	R.durationfire = Clamp(R.durationfire, ammo.reagents.min_fire_dur, ammo.reagents.max_fire_dur)
	R.rangefire = Clamp(R.rangefire, ammo.reagents.min_fire_rad, ammo.reagents.max_fire_rad)
	var/max_range = R.rangefire
	if (max_range < fuel_pressure) //Used for custom tanks, allows for higher ranges
		max_range = Clamp(fuel_pressure, 0, ammo.reagents.max_fire_rad)
	if(R.rangefire == -1)
		max_range = ammo.reagents.max_fire_rad

	var/turf/temp[] = getline2(get_turf(owner), get_turf(target))

	var/turf/to_fire = temp[2]

	var/obj/flamer_fire/fire = locate() in to_fire
	if(fire)
		qdel(fire)

	playsound(to_fire, src.get_fire_sound(), 50, TRUE)
	ammo.current_rounds = ammo.reagents.total_volume

	new /obj/flamer_fire(to_fire, create_cause_data(initial(name), owner.seats[VEHICLE_DRIVER]), R, max_range, ammo.reagents, flameshape, target, CALLBACK(src, PROC_REF(show_percentage), owner.seats[VEHICLE_DRIVER]), fuel_pressure, fire_type)

	if(ammo.current_rounds <= 0 || !ammo)
		to_chat(owner.seats[VEHICLE_DRIVER], "<span class='warning'>WARNING! System report: ammunition is depleted!</span>")
		ammo.loc = owner.loc
		ammo = null
		visible_message("[owner.name]'s systems deployed used magazine.","")
		return

/obj/item/walker_gun/flamer/proc/show_percentage(mob/living/user)
	if(ammo)
		to_chat(user, SPAN_WARNING("System Report: <b>[round(ammo.get_ammo_percent())]</b>% fuel remains!"))

///////////////
// AMMO MAGS // START
///////////////

/obj/item/ammo_magazine/walker
	w_class = SIZE_LARGE
	icon = 'fray-marines/icons/obj/vehicles/mecha_guns.dmi'

/obj/item/ammo_magazine/walker/smartgun
	name = "M56 Double-Barrel Magazine (Standard)"
	desc = "A armament MG magazine"
	caliber = "10x28mm" //Correlates to smartguns
	icon_state = "mech_smartgun_ammo"
	default_ammo = /datum/ammo/bullet/walker/smartgun
	max_rounds = 700
	gun_type = /obj/item/walker_gun/smartgun

/*
/obj/item/ammo_magazine/walker/smartgun/ap
	name = "M56 Double-Barrel Magazine (AP)"
	desc = "A armament MG magazine"
	caliber = "10x28mm" //Correlates to smartguns
	icon_state = "big_ammo_box_ap"
	default_ammo = /datum/ammo/bullet/smartgun/walker/ap
	max_rounds = 500
	gun_type = /obj/item/walker_gun/smartgun
/obj/item/ammo_magazine/walker/smartgun/incendiary
	name = "M56 Double-Barrel \"Scorcher\" Magazine"
	desc = "A armament MG magazine"
	caliber = "10x28mm" //Correlates to smartguns
	icon_state = "ammoboxslug"
	default_ammo = /datum/ammo/bullet/smartgun/walker/incendiary
	max_rounds = 500
	gun_type = /obj/item/walker_gun/smartgun
*/

/obj/item/ammo_magazine/walker/hmg
	name = "M30 Machine Gun Magazine"
	desc = "A armament M30 magazine"
	icon_state = "mech_minigun_ammo"
	max_rounds = 400
	default_ammo = /datum/ammo/bullet/walker/machinegun
	gun_type = /obj/item/walker_gun/hmg

/obj/item/ammo_magazine/walker/flamer
	name = "F40 UT-Napthal Canister"
	desc = "Canister for mounted flamethower"
	icon_state = "mech_flamer_s_ammo"
	max_rounds = 300
	default_ammo = /datum/ammo/flamethrower
	gun_type = /obj/item/walker_gun/flamer
	flags_magazine = AMMUNITION_HIDE_AMMO

	var/flamer_chem = "utnapthal"

	var/max_intensity = 40
	var/max_range = 5
	var/max_duration = 30

	var/fuel_pressure = 1 //How much fuel is used per tile fired
	var/max_pressure = 10

/obj/item/ammo_magazine/walker/flamer/Initialize(mapload, ...)
	. = ..()
	create_reagents(max_rounds)

	if(flamer_chem)
		reagents.add_reagent(flamer_chem, max_rounds)

	reagents.min_fire_dur = 1
	reagents.min_fire_int = 1
	reagents.min_fire_rad = 1

	reagents.max_fire_dur = max_duration
	reagents.max_fire_rad = max_range
	reagents.max_fire_int = max_intensity

/obj/item/ammo_magazine/walker/flamer/get_ammo_percent()
	if(!reagents)
		return 0

	return 100 * (reagents.total_volume / max_rounds)

// /obj/item/ammo_magazine/walker/flamer/ex
// 	name = "F40 UT-Napthal EX-type Canister"
// 	desc = "Canister for mounted flamethower"
// 	icon_state = "mech_flamer_ex_ammo"
// 	max_rounds = 300
// 	default_ammo = /datum/ammo/flamethrower
// 	gun_type = /obj/item/walker_gun/flamer

// 	flamer_chem = "napalmex"

// 	max_intensity = 40
// 	max_range = 5
// 	max_duration = 30

// 	fuel_pressure = 1 //How much fuel is used per tile fired
// 	max_pressure = 10

/obj/item/ammo_magazine/walker/flamer/btype
	name = "F40 UT-Napthal B-type Canister"
	desc = "Canister for mounted flamethower"
	icon_state = "mech_flamer_b_ammo"
	max_rounds = 300
	default_ammo = /datum/ammo/flamethrower
	gun_type = /obj/item/walker_gun/flamer

	flamer_chem = "napalmb"

	max_intensity = 40
	max_range = 5
	max_duration = 30

	fuel_pressure = 1 //How much fuel is used per tile fired
	max_pressure = 10
///////////////
// AMMO MAGS // END
///////////////

/datum/ammo/bullet/walker/smartgun
	name = "smartgun bullet"
	icon_state = "redbullet"
	flags_ammo_behavior = AMMO_BALLISTIC

	max_range = 24
	accuracy = HIT_ACCURACY_TIER_5
	damage = 35
	penetration = 0

/datum/ammo/bullet/walker/machinegun
	name = "machinegun bullet"
	icon_state = "bullet"

	accurate_range = 12
	damage = 45
	penetration= ARMOR_PENETRATION_TIER_10
	accuracy = HIT_ACCURACY_TIER_3

////////////////
// MEGALODON HARDPOINTS // END
////////////////

/datum/supply_packs/ammo_m56_walker
	name = "M56 Double-Barrel magazines (x2)"
	contains = list(
		/obj/item/ammo_magazine/walker/smartgun,
		/obj/item/ammo_magazine/walker/smartgun,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "M56 Double-Barrel ammo crate"
	group = "Vehicle Ammo"

/datum/supply_packs/ammo_M30_walker
	name = "M30 Machine Gun magazines (x2)"
	contains = list(
		/obj/item/ammo_magazine/walker/hmg,
		/obj/item/ammo_magazine/walker/hmg,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "M30 Machine Gun ammo crate"
	group = "Vehicle Ammo"

/datum/supply_packs/ammo_F40_walker
	name = "F40 Flamethower Mixed magazines (UT-Napthal x1, B-Type x1)"
	contains = list(
		/obj/item/ammo_magazine/walker/flamer,
		/obj/item/ammo_magazine/walker/flamer/btype,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "F40 Flamethower ammo crate"
	group = "Vehicle Ammo"

////////////////
// MEGALODON SUPPLYPACKS // END
////////////////
