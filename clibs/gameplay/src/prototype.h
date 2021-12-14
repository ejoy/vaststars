#if !defined(prototype_h) || defined(PROTOTYPE_IMPLEMENTATION)
#define prototype_h

#include "prototype_imp.h"

// powergrid
PROTOTYPE(power, float)
PROTOTYPE(drain, float)
PROTOTYPE(priority, int)	// power priority
PROTOTYPE(efficiency, float)	// power convert efficiency
PROTOTYPE(charge_power, float)	// battrty charge power
PROTOTYPE(battery, float)	// battery capacity
PROTOTYPE(fuel_energy, float)
PROTOTYPE(stack, int)
PROTOTYPE(time, int)
PROTOTYPE(ingredients, string)
PROTOTYPE(results, string)
PROTOTYPE(speed, int)

#endif
