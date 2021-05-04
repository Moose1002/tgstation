/obj/machinery/power/diesel_gen
	name = "diesel generator"
	desc = "An old generator from the past, generating large amounts of power, while requiring more fuel and upkeep than modern day power generators. This should probably only be used as a last resort."
	icon = 'icons/obj/machines/diesel_generator.dmi'
	icon_state = "diesel_gen0"
	circuit = /obj/item/circuitboard/machine/diesel_gen
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE

	var/active = FALSE
	var/power_gen = 5000
	var/power_output = 1
	var/consumption = 0
	var/fuel = 0
	var/max_fuel = 100
	var/fuel_name = ""
	var/fuel_path = /obj/item/stack/sheet/mineral/plasma
	var/fuel_left = 0 // How much is left of the sheet
	var/time_per_unit = 260
	var/current_heat = 0
	var/base_icon = "portgen2_0"
	var/datum/looping_sound/generator/soundloop

	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_REQUIRES_ANCHORED

/obj/machinery/power/diesel_gen/Initialize()
	. = ..()
	soundloop = new(list(src), active)

/obj/machinery/power/diesel_gen/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/power/diesel_gen/should_have_node()
	return anchored

/obj/machinery/power/diesel_gen/connect_to_network()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/power/diesel_gen_segment
	name = "diesel generator"
	desc = "An old generator from the past, generating large amounts of power, while requiring more fuel and upkeep than modern day power generators. This should probably only be used as a last resort."
	icon = 'icons/obj/machines/diesel_generator.dmi'
	icon_state = "diesel_gen0"
	anchored = TRUE
	density = TRUE

/obj/machinery/power/diesel_gen_segment/bottom_middle
	icon_state = "diesel_gen1"

/obj/machinery/power/diesel_gen_segment/bottom_right
	icon_state = "diesel_gen2"

/obj/machinery/power/diesel_gen_segment/bottom_right/Initialize()
	. = ..()
	var/year = rand(2005, 2025)
	desc = "The year the generator was made seems to be engraved into the side. It reads [year]."

/obj/machinery/power/diesel_gen_segment/top_left
	icon_state = "diesel_gen3"

/obj/machinery/power/diesel_gen_segment/top_middle
	icon_state = "diesel_gen4"

/obj/machinery/power/diesel_gen_segment/top_right
	icon_state = "diesel_gen5"
