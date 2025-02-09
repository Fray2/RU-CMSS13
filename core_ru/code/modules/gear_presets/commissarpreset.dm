/datum/equipment_preset/uscm/commissar
	name = "USCM Commissar"
	paygrades = list(PAY_SHORT_MO2, "MO2")
	flags = EQUIPMENT_PRESET_START_OF_ROUND|EQUIPMENT_PRESET_MARINE
	assignment = "USCM Commissar"
	idtype = /obj/item/card/id/gold
	rank = JOB_COMMISSAR
	role_comm_title = "UMCR"
	minimum_age = 23
	languages = list(LANGUAGE_ENGLISH)
	skills = /datum/skills/commissar/commissar
	minimap_icon = "cmsr"
	minimap_background = "background_cmsr"

/datum/equipment_preset/uscm/commissar/New()
	. = ..()
	access = get_access(ACCESS_LIST_MARINE_MAIN)

/datum/equipment_preset/uscm/commissar/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_NORMAL

/datum/equipment_preset/uscm/commissar/load_gear(mob/living/carbon/human/new_human)
	var/back_item = /obj/item/storage/backpack/satchel
	if (new_human.client && new_human.client.prefs && (new_human.client.prefs.backbag == 1))
		back_item = /obj/item/storage/backpack/marine

	new_human.equip_to_slot_or_del(new back_item(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom/cdrcom(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/beret/cm(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/jacket/marine/service(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/boiler, WEAR_BODY)
