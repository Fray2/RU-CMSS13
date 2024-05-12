/*
---------------------
COLONIAL MARSHALS
---------------------
*/
/datum/skills/cmb
	name = "CMB Deputy"
	skills = list(
		SKILL_POLICE = SKILL_POLICE_SKILLED,
		SKILL_CQC = SKILL_CQC_EXPERT,
		SKILL_CONSTRUCTION = SKILL_CONSTRUCTION_DEFAULT,
		SKILL_FIREARMS = SKILL_FIREARMS_TRAINED,
		SKILL_FIREMAN = SKILL_FIREMAN_SKILLED,
		SKILL_MEDICAL = SKILL_MEDICAL_TRAINED,
		SKILL_MELEE_WEAPONS = SKILL_MELEE_TRAINED,
		SKILL_JTAC = SKILL_JTAC_BEGINNER,
		SKILL_ENDURANCE = SKILL_ENDURANCE_MASTER,
	)

/datum/skills/cmb/leader
	name = "CMB Marshal"
	skills = list(
		SKILL_POLICE = SKILL_POLICE_SKILLED,
		SKILL_CQC = SKILL_CQC_EXPERT,
		SKILL_CONSTRUCTION = SKILL_CONSTRUCTION_ENGI,
		SKILL_LEADERSHIP = SKILL_LEAD_MASTER,
		SKILL_OVERWATCH = SKILL_OVERWATCH_TRAINED,
		SKILL_MEDICAL = SKILL_MEDICAL_MEDIC,
		SKILL_ENGINEER = SKILL_ENGINEER_ENGI,
		SKILL_FIREMAN = SKILL_FIREMAN_MASTER,
		SKILL_FIREARMS = SKILL_FIREARMS_MAX,
		SKILL_MELEE_WEAPONS = SKILL_MELEE_TRAINED,
		SKILL_VEHICLE = SKILL_VEHICLE_SMALL,
		SKILL_ENDURANCE = SKILL_ENDURANCE_EXPERT,
		SKILL_JTAC = SKILL_JTAC_EXPERT,
	)

/datum/skills/synthetic/cmb
	name = "CMB Investigative Synthetic"
	skills = list(
		SKILL_CQC = SKILL_CQC_MASTER,
		SKILL_ENGINEER = SKILL_ENGINEER_MASTER,
		SKILL_CONSTRUCTION = SKILL_CONSTRUCTION_MASTER,
		SKILL_FIREARMS = SKILL_FIREARMS_TRAINED,
		SKILL_SPEC_WEAPONS = SKILL_SPEC_ALL,
		SKILL_LEADERSHIP = SKILL_LEAD_EXPERT, // incase the synth needs to use consoles for investigations or tracking
		SKILL_OVERWATCH = SKILL_OVERWATCH_TRAINED,
		SKILL_MEDICAL = SKILL_MEDICAL_DOCTOR,
		SKILL_SURGERY = SKILL_SURGERY_TRAINED, // Not a medical Synthetic, but operate if absolutely needed.
		SKILL_RESEARCH = SKILL_RESEARCH_TRAINED,
		SKILL_MELEE_WEAPONS = SKILL_MELEE_SUPER,
		SKILL_PILOT = SKILL_PILOT_TRAINED,
		SKILL_POLICE = SKILL_POLICE_SKILLED,
		SKILL_FIREMAN = SKILL_FIREMAN_MAX,
		SKILL_POWERLOADER = SKILL_POWERLOADER_MASTER,
		SKILL_VEHICLE = SKILL_VEHICLE_LARGE,
		SKILL_JTAC = SKILL_JTAC_BEGINNER,
		SKILL_INTEL = SKILL_INTEL_EXPERT,
		SKILL_DOMESTIC = SKILL_DOMESTIC_MASTER
	)
