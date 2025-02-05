/obj/structure/machinery/cm_vending/clothing/commissar
	name = "\improper ColMarTech USCM Commissar Equipment Rack"
	desc = "An automated equipment vendor for USCM Commissar."
	req_access = list(ACCESS_MARINE_COMMAND)
	vendor_role = list(JOB_SO, JOB_COMMISSAR)

/obj/structure/machinery/cm_vending/clothing/commissar/get_listed_products(mob/user)
	return GLOB.cm_vending_clothing_commissar

//------------------------------Clothing--------------------------

GLOBAL_LIST_INIT(cm_vending_clothing_commissar, list(
		list("STANDARD EQUIPMENT(TAKE ALL)", 0, null, null, null),
		list("Boots", 0, /obj/item/clothing/shoes/marine/knife, MARINE_CAN_BUY_COMBAT_SHOES, VENDOR_ITEM_MANDATORY),
		list("Headset", 0, /obj/item/device/radio/headset/almayer/mcom, MARINE_CAN_BUY_EAR, VENDOR_ITEM_MANDATORY),
		list("MRE", 0, /obj/item/storage/box/MRE, MARINE_CAN_BUY_MRE, VENDOR_ITEM_MANDATORY),


		list("ARMOR AND HELMETS(ONE HELMET AND ONE ARMOR)", 0, null, null, null),
		list("MP Beret", 0, /obj/item/clothing/head/beret/marine/mp, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_REGULAR),
		list("Officer Beret", 0, /obj/item/clothing/head/beret/marine/chiefofficer, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_REGULAR),
		list("Service Peaked Cap", 0, /obj/item/clothing/head/marine/peaked/service, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_REGULAR),
		list("Patrol Cap", 0, /obj/item/clothing/head/cmcap, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_REGULAR),
		list("Officer Cap", 0, /obj/item/clothing/head/cmcap/bridge, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_REGULAR),
		list("Officer M10 Helmet", 0, /obj/item/clothing/head/helmet/marine/MP/SO, MARINE_CAN_BUY_COMBAT_HELMET, VENDOR_ITEM_MANDATORY),
		list("Officer M3 Armor", 0, /obj/item/clothing/suit/storage/marine/MP/SO, MARINE_CAN_BUY_COMBAT_ARMOR, VENDOR_ITEM_MANDATORY),
		list("Marine Combat Gloves", 0, /obj/item/clothing/gloves/marine, MARINE_CAN_BUY_GLOVES, VENDOR_ITEM_MANDATORY),

		list("SPECIALISATION KIT (CHOOSE 1)", 0, null, null, null),
		list("Essential Engineer Set", 0, /obj/effect/essentials_set/engi, MARINE_CAN_BUY_ESSENTIALS, VENDOR_ITEM_RECOMMENDED),
		list("Essential Medical Set", 0, /obj/effect/essentials_set/medic, MARINE_CAN_BUY_ESSENTIALS, VENDOR_ITEM_RECOMMENDED),

		list("PERSONAL WEAPON (CHOOSE 1)", 0, null, null, null),
		list("VP78 Pistol", 0, /obj/item/storage/belt/gun/m4a3/vp78, MARINE_CAN_BUY_SECONDARY, VENDOR_ITEM_REGULAR),
		list("M4A3 Service Pistol", 0, /obj/item/storage/belt/gun/m4a3/commander, MARINE_CAN_BUY_SECONDARY, VENDOR_ITEM_REGULAR),
		list("Mod 88 Pistol", 0, /obj/item/storage/belt/gun/m4a3/mod88, MARINE_CAN_BUY_SECONDARY, VENDOR_ITEM_REGULAR),
		list("M44 Revolver", 0, /obj/item/storage/belt/gun/m44/mp, MARINE_CAN_BUY_SECONDARY, VENDOR_ITEM_REGULAR),
		list("CSPR Revolver", 0, /obj/item/storage/belt/gun/m44/cspr, MARINE_CAN_BUY_SECONDARY, VENDOR_ITEM_RECOMMENDED),

		list("EXPLOSIVES", 0, null, null, null),
		list("HEDP Grenade Pack", 15, /obj/item/storage/box/packet/high_explosive, null, VENDOR_ITEM_REGULAR),
		list("HEFA Grenade Pack", 15, /obj/item/storage/box/packet/hefa, null, VENDOR_ITEM_REGULAR),
		list("WP Grenade Pack", 15, /obj/item/storage/box/packet/phosphorus, null, VENDOR_ITEM_REGULAR),

		list("BELTS (CHOOSE 1)", 0, null, null, null),
		list("G8-A General Utility Pouch", 0, /obj/item/storage/backpack/general_belt, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 Ammo Load Rig", 0, /obj/item/storage/belt/marine, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("M276 Shotgun Shell Loading Rig", 0, /obj/item/storage/belt/shotgun, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("M276 Toolbelt Rig (Full)", 0, /obj/item/storage/belt/utility/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("M276 Holster Toolrig (Full)", 0, /obj/item/storage/belt/gun/utility/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 Lifesaver Bag (Full)", 0, /obj/item/storage/belt/medical/lifesaver/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("M276 Medical Storage Rig (Full)", 0, /obj/item/storage/belt/medical/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 M39 Holster Rig", 0, /obj/item/storage/belt/gun/m39, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 M82F Holster Rig", 0, /obj/item/storage/belt/gun/flaregun, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 M40 Grenade Rig", 0, /obj/item/storage/belt/grenade, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("Military Police Belt", 0, /obj/item/storage/belt/security/MP/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("M276 Pattern General Revolver Holster Rig", 0, /obj/item/storage/belt/gun/m44, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),

		list("ACCESSORIES (CHOOSE 1)", 0, null, null, null),
		list("Brown Webbing Vest", 0, /obj/item/clothing/accessory/storage/black_vest/brown_vest, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_RECOMMENDED),
		list("Black Webbing Vest", 0, /obj/item/clothing/accessory/storage/black_vest, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Tactical Waistcoat", 0, /obj/item/clothing/accessory/storage/black_vest/waistcoat, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Shoulder Holster", 0, /obj/item/clothing/accessory/storage/holster, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Webbing", 0, /obj/item/clothing/accessory/storage/webbing, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Drop Pouch", 0, /obj/item/clothing/accessory/storage/droppouch, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),

		list("POUCHES (CHOOSE 2)", 0, null, null, null),
		list("First-Aid Pouch (Refillable Injectors)", 0, /obj/item/storage/pouch/firstaid/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("First-Aid Pouch (Splints, Gauze, Ointment)", 0, /obj/item/storage/pouch/firstaid/full/alternate, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("First-Aid Pouch (Pill Packets)", 0, /obj/item/storage/pouch/firstaid/full/pills, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Medical Kit Pouch", 0, /obj/item/storage/pouch/medkit, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Autoinjector Pouch", 0, /obj/item/storage/pouch/autoinjector/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Large General Pouch", 0, /obj/item/storage/pouch/general/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Large Pistol Magazine Pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Large Magazine Pouch", 0, /obj/item/storage/pouch/magazine/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Sidearm Pouch", 0, /obj/item/storage/pouch/pistol, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Large Shotgun Shell Pouch", 0, /obj/item/storage/pouch/shotgun/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Tools Pouch (Full)", 0, /obj/item/storage/pouch/tools/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Machete Pouch (Full)", 0, /obj/item/storage/pouch/machete/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),

	))
