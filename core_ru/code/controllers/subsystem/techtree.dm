/datum/controller/subsystem/techtree/fire()
	for(var/name in trees)
		var/datum/techtree/tree_income = trees[name]
		tree_income.add_points(0.1*UNIVERSAL_TECH_POINTS_MULTIPLICATOR) // 6 поинов час, 2 поинта до высадки
