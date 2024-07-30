/*
---------------------
MISCELLANEOUS
---------------------
*/

/datum/skills/tank_crew
	name = "Vehicle Crewman"
	skills = list(
		SKILL_VEHICLE = SKILL_VEHICLE_CREWMAN,
		SKILL_LEADERSHIP = SKILL_LEAD_EXPERT,
		SKILL_OVERWATCH = SKILL_OVERWATCH_TRAINED,
		SKILL_POWERLOADER = SKILL_POWERLOADER_MASTER,
		SKILL_ENGINEER = SKILL_ENGINEER_ENGI,
		SKILL_FIREMAN = SKILL_FIREMAN_TRAINED,
		SKILL_LEADERSHIP = SKILL_LEAD_TRAINED,
		SKILL_JTAC = SKILL_JTAC_EXPERT,
	)

/datum/skills/yautja/warrior
	name = "Yautja Warrior"
	skills = list(
		SKILL_CQC = SKILL_CQC_MASTER,
		SKILL_MELEE_WEAPONS = SKILL_MELEE_SUPER,
		SKILL_ENDURANCE = SKILL_ENDURANCE_MASTER,
		SKILL_ENGINEER = SKILL_ENGINEER_ENGI,
		SKILL_CONSTRUCTION = SKILL_CONSTRUCTION_ENGI,
		SKILL_MEDICAL = SKILL_MEDICAL_MEDIC,
		SKILL_SURGERY = SKILL_SURGERY_EXPERT,
		SKILL_POLICE = SKILL_POLICE_SKILLED,
		SKILL_FIREMAN = SKILL_FIREMAN_MAX,
		SKILL_ANTAG = SKILL_ANTAG_HUNTER,
	)

/datum/skills/cultist_leader
	name = "Cultist Leader"
	skills = list(
		SKILL_FIREARMS = SKILL_FIREARMS_CIVILIAN,
		SKILL_CQC = SKILL_CQC_MASTER,
		SKILL_FIREMAN = SKILL_FIREMAN_TRAINED,
		SKILL_MELEE_WEAPONS = SKILL_MELEE_SUPER,
		SKILL_CONSTRUCTION = SKILL_CONSTRUCTION_MASTER,
		SKILL_ENGINEER = SKILL_ENGINEER_MASTER,
		SKILL_MEDICAL = SKILL_MEDICAL_MEDIC,
		SKILL_LEADERSHIP = SKILL_LEAD_MASTER,
		SKILL_OVERWATCH = SKILL_OVERWATCH_TRAINED,
		SKILL_ENDURANCE = SKILL_ENDURANCE_MAX,
		SKILL_JTAC = SKILL_JTAC_MASTER,
	)

/datum/skills/souto
	name = "Souto Man"
	skills = list(
		SKILL_CQC = SKILL_CQC_MASTER,
		SKILL_ENGINEER = SKILL_ENGINEER_ENGI,
		SKILL_CONSTRUCTION = SKILL_CONSTRUCTION_ENGI,
		SKILL_FIREARMS = SKILL_FIREARMS_EXPERT,
		SKILL_MEDICAL = SKILL_MEDICAL_TRAINED,
		SKILL_MELEE_WEAPONS = SKILL_MELEE_TRAINED,
		SKILL_JTAC = SKILL_JTAC_BEGINNER,
		SKILL_SPEC_WEAPONS = SKILL_SPEC_ALL,
	)

/datum/skills/everything //max it out
	name = "Ultra"
	skills = list(
		SKILL_CQC = SKILL_CQC_MAX,
		SKILL_MELEE_WEAPONS = SKILL_MELEE_MAX,
		SKILL_FIREARMS = SKILL_FIREARMS_MAX,
		SKILL_SPEC_WEAPONS = SKILL_SPEC_ALL,
		SKILL_ENDURANCE = SKILL_ENDURANCE_MAX,
		SKILL_ENGINEER = SKILL_ENGINEER_MAX,
		SKILL_CONSTRUCTION = SKILL_CONSTRUCTION_MAX,
		SKILL_LEADERSHIP = SKILL_LEAD_MAX,
		SKILL_OVERWATCH = SKILL_OVERWATCH_MAX,
		SKILL_MEDICAL = SKILL_MEDICAL_MAX,
		SKILL_SURGERY = SKILL_SURGERY_MAX,
		SKILL_RESEARCH = SKILL_RESEARCH_MAX,
		SKILL_ANTAG = SKILL_ANTAG_MAX,
		SKILL_PILOT = SKILL_PILOT_MAX,
		SKILL_POLICE = SKILL_POLICE_MAX,
		SKILL_FIREMAN = SKILL_FIREMAN_MAX,
		SKILL_POWERLOADER = SKILL_POWERLOADER_MAX,
		SKILL_VEHICLE = SKILL_VEHICLE_MAX,
		SKILL_JTAC = SKILL_JTAC_MAX,
		SKILL_EXECUTION = SKILL_EXECUTION_MAX,
		SKILL_INTEL = SKILL_INTEL_MAX,
	)
