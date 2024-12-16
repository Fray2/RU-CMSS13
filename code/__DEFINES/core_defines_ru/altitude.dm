//Defines what to times the OB and transport shuttle timers by based on the altitude
#define SHIP_ALT_LOW 0.5
#define SHIP_ALT_MED 1
#define SHIP_ALT_HIGH 1.5

//List of available heights
GLOBAL_VAR_INIT(ship_alt_list, list("Low Altitude" = SHIP_ALT_LOW, "Optimal Altitude" = SHIP_ALT_MED, "High Altitude" = SHIP_ALT_HIGH))

//Has the ships temperature set to 0 on startup, sets the global default var to med
GLOBAL_VAR_INIT(ship_temp, 0)
GLOBAL_VAR_INIT(ship_alt, SHIP_ALT_MED)
